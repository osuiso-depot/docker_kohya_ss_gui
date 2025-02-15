#!/bin/false

source /opt/ai-dock/etc/environment.sh

build_common_main() {
    # Nothing to do
    :
}

build_common_install_kohya_ss() {
    # Get latest tag from GitHub if not provided
    if [[ -z $KOHYA_BUILD_REF ]]; then
        export KOHYA_BUILD_REF="sd3-flux.1-uv"
        env-store KOHYA_BUILD_REF
    fi

    cd /opt
    # すでに存在する場合は削除してからクローン
    [ -d kohya_ss ] && rm -rf kohya_ss
    git clone --recursive https://github.com/bmaltais/kohya_ss kohya_ss
    cd /opt/kohya_ss

    # 最新のコードに切り替え（タグではなくmainブランチを利用）
    git checkout "$KOHYA_BUILD_REF"
    git pull origin "$KOHYA_BUILD_REF"

    printf "\n%s\n" '#myTensorButton, #myTensorButtonStop {display:none!important;}' >> assets/style.css
    "$KOHYA_VENV_PIP" install --no-cache-dir \
        tensorboard \
        -r requirements.txt
}


build_common_run_tests() {
    installed_pytorch_version=$("$KOHYA_VENV_PYTHON" -c "import torch; print(torch.__version__)")
    if [[ "$installed_pytorch_version" != "$PYTORCH_VERSION"* ]]; then
        echo "Expected PyTorch ${PYTORCH_VERSION} but found ${installed_pytorch_version}\n"
        exit 1
    fi
}

build_common_main "$@"
