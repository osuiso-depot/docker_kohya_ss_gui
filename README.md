# Kohya's GUI (kohya_ss) Docker Image (Optimized for Vast.ai)

このリポジトリは、[Kohya's GUI (kohya_ss)](https://github.com/bmaltais/kohya_ss) を Docker 環境（ローカルまたは Vast.ai などのクラウド）で動作させるためのイメージを提供します。
[AI-Dock](https://github.com/ai-dock) のベースイメージを基に、Vast.ai での利用に最適化し、ビルド速度とイメージサイズの改善を行っています。

## 変更まとめ
* `torch==2.4.0`
* `kohya_ss sd3`に対応
* `kohya_ss`イメージを`cuda-12.1.1-base-22.04-sd3-flux.1`にした
* `sd-script`を`sd3-flux.1`ブランチを使用するようにした
* BaseImageを`v2-cuda-12.1.1-cudnn8-runtime-22.04`にした
* バグ修正:`ValueError: torch.cuda.is_available() should be True but is False. xformers' memory efficient attention is only available for GPU`
* provisioningスクリプトの修正。

## 本格的なフォークによる改善点

オリジナル（AI-Dock版）と比較して、以下の最適化を行っています：

1. **イメージサイズの削減**:
   - 巨大な `tensorrt` パッケージを削除し、デプロイ時間を短縮。
   - レイヤーごとのクリーンアップ（APT lists の削除など）を徹底。
2. **ビルド速度の向上**:
   - `git clone --depth 1` による浅いクローニングを採用。
3. **安定性とバグ修正**:
   - Gradio 5 系統で発生するランタイムエラーを修正（`pydantic` のバージョン固定、`--listen 0.0.0.0` の強制適用）。
   - PyTorch 2.4.0 / CUDA 12.1 環境への最適化。
4. **使いやすさの向上**:
   - Docker Compose によるビルド・プッシュ・タグ管理の簡略化。

## クイックスタート

### 1. 起動方法（ローカル環境）

```powershell
docker compose up -d
```
起動後、ブラウザで `http://localhost:7860`（または設定したポート）にアクセスしてください。

### 2. Vast.ai での利用
[provisioning.sh](config/provisioning/default.sh) を使用して、起動時に自動的にモデルや必要な拡張機能をインストールするように設定できます。

## ビルドとプッシュの手順

開発者や独自のビルドが必要な場合は、以下の手順で行います。

### ローカルでのビルド
```powershell
# デフォルト（latest）タグでビルド
docker compose build

# 特定のタグを指定してビルド
$env:IMAGE_TAG="v2.1.0"; docker compose build
```

### Docker Hub へのプッシュ
```powershell
# ログイン（初回のみ）
docker login

# プッシュ
docker compose push
```

## 主な環境変数

| 変数名            | 説明                             | デフォルト値 |
| :---------------- | :------------------------------- | :----------- |
| `IMAGE_TAG`       | ビルド・プッシュ時のイメージタグ | `latest`     |
| `KOHYA_PORT_HOST` | ホスト側で公開するポート         | `7860`       |
| `WEB_USER`        | 認証用ユーザー名                 | `user`       |
| `WEB_PASSWORD`    | 認証用パスワード                 | `password`   |
| `KOHYA_ARGS`      | kohya_ss 起動時の追加引数        | (なし)       |

詳細な AI-Dock ベースの変数は [Base Image Wiki](https://github.com/ai-dock/base-image/wiki/2.0-Environment-Variables) を参照してください。

## 構成

- **OS**: Ubuntu 22.04
- **Python**: 3.10
- **PyTorch**: 2.4.0
- **CUDA**: 12.1.1
- **Venv**: `/opt/environments/python/kohya`

---
*本プロジェクトは AI-Dock プロジェクトをベースに、特定のワークフロー向けにカスタマイズされたものです。*
