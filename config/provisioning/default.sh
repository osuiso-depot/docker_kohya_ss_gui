#!/bin/bash
# This file will be sourced in init.sh
# Namespace functions with provisioning_

# https://raw.githubusercontent.com/ai-dock/kohya_ss/main/config/provisioning/default.sh

### Edit the following arrays to suit your workflow - values must be quoted and separated by newlines or spaces.

DISK_GB_REQUIRED=24

PIP_PACKAGES=(
    #"package==version"
    # "schedulefree==1.4"
  )

CHECKPOINT_MODELS=(
    "https://huggingface.co/rimOPS/IllustriousBased/resolve/main/vxpILXL_v17.safetensors"
)


function myconfig(){
    cd "${WORKSPACE}"

    mkdir -p "${WORKSPACE}/tmp"
    if [ $? -ne 0 ]; then
        echo "Failed to create tmp directory"
    fi


    # ダウンロードするファイルのURL
    file_url="https://github.com/osuiso-depot/kohya_ss_gui_config/raw/main/kohya_config.json"
    # パーソナルアクセストークン
    token="${GITHUB_TOKEN}"

    # ファイル名を取得
    file_name=$(basename "$file_url")

    # curlコマンドでダウンロード
    curl -H "Authorization: token $token" -L "$file_url" -o "$file_name"

    # 結果を確認
    if [ $? -eq 0 ]; then
        echo "Download successful: $file_name"

        # kohya_config.json を目的のディレクトリに移動
        mv "kohya_config.json" "${WORKSPACE}/kohya_ss"
        if [ $? -ne 0 ]; then
            echo "Failed move kohya_config.json"
        fi

    else
        echo "Download failed"
    fi

    cd "${WORKSPACE}/kohya_ss"

}

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    source /opt/ai-dock/etc/environment.sh
    source /opt/ai-dock/bin/venv-set.sh kohya

    DISK_GB_AVAILABLE=$(($(df --output=avail -m "${WORKSPACE}" | tail -n1) / 1000))
    DISK_GB_USED=$(($(df --output=used -m "${WORKSPACE}" | tail -n1) / 1000))
    DISK_GB_ALLOCATED=$(($DISK_GB_AVAILABLE + $DISK_GB_USED))
    provisioning_print_header
    provisioning_get_mamba_packages
    provisioning_get_pip_packages
    myconfig
    provisioning_get_models \
        "${WORKSPACE}/kohya_ss/models" \
        "${CHECKPOINT_MODELS[@]}"

    provisioning_print_end
}

function provisioning_get_pip_packages() {
    if [[ -n $PIP_PACKAGES ]]; then
        "$KOHYA_VENV_PIP" install --no-cache-dir ${PIP_PACKAGES[@]}
    fi
}

function provisioning_get_models() {
    if [[ -z $2 ]]; then return 1; fi
    dir="$1"
    mkdir -p "$dir"
    shift
    if [[ $DISK_GB_ALLOCATED -ge $DISK_GB_REQUIRED ]]; then
        arr=("$@")
    else
        printf "WARNING: Low disk space allocation - Only the first model will be downloaded!\n"
        arr=("$1")
    fi

    printf "Downloading %s model(s) to %s...\n" "${#arr[@]}" "$dir"
    for url in "${arr[@]}"; do
        printf "Downloading: %s\n" "${url}"
        provisioning_download "${url}" "${dir}"
        printf "\n"
    done
}

function provisioning_print_header() {
    printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
    if [[ $DISK_GB_ALLOCATED -lt $DISK_GB_REQUIRED ]]; then
        printf "WARNING: Your allocated disk size (%sGB) is below the recommended %sGB - Some models will not be downloaded\n" "$DISK_GB_ALLOCATED" "$DISK_GB_REQUIRED"
    fi
}

function provisioning_print_end() {
    printf "\nProvisioning complete:  Web UI will start now\n\n"
}

# Download from $1 URL to $2 file path
function provisioning_download() {
    # 認証トークンを選択
    if [[ $1 =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]]; then
        auth_token="$HF_TOKEN"
        if [[ -n $auth_token ]]; then
            echo "Downloading with token..."
            wget --header="Authorization: Bearer $auth_token" --content-disposition --show-progress -q -P "$2" "$1"
        else
            echo "Downloading without token..."
            wget --content-disposition --show-progress -q -P "$2" "$1"
        fi
    elif [[ $1 =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com(/|/api/download/models/|$|\?) ]]; then
        auth_token="$CIVITAI_TOKEN"
        if [[ -n $auth_token ]]; then
            echo "Downloading with token..."
            wget "$1?token=$auth_token" --content-disposition --show-progress -q -P "$2"
        else
            echo "Downloading without token..."
            wget "$1" --content-disposition --show-progress -q -P "$2"
        fi
    fi

}

provisioning_start
