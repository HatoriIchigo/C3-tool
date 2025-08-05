# AWS S3バケットリスト取得ツール 使用方法

## 環境構築

このツールを実行するために必要な環境設定を以下に記載します。

### 1. AWS CLIのインストール
```bash
# Ubuntu/Debian系の場合
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# macOSの場合（Homebrew使用）
brew install awscli

# Windowsの場合
# AWS CLI公式サイトからインストーラーをダウンロードして実行
```

### 2. AWS認証情報の設定
```bash
# AWSプロファイルの設定
aws configure
# または特定のプロファイル名で設定
aws configure --profile your-profile-name
```

設定が必要な項目：
- AWS Access Key ID
- AWS Secret Access Key  
- Default region name (例: ap-northeast-1)
- Default output format (例: json)

### 3. 実行権限の付与
```bash
chmod +x tools/get-s3-list.sh
```

## ツールの使い方

### 基本的な使い方

#### 全てのS3バケット一覧を取得
```bash
./tools/get-s3-list.sh
```

#### 特定の文字列を含むバケットのみを取得
```bash
./tools/get-s3-list.sh --bucket mybucket
```
- 引数: `--bucket`
  - バケット名に含まれる文字列を指定
  - 指定した文字列を含むバケットのみが表示される
  - 省略した場合は全てのバケットが表示される

#### 特定のAWSプロファイルを使用
```bash
./tools/get-s3-list.sh --profile production
```
- 引数: `--profile`
  - 使用するAWSプロファイル名を指定
  - 省略した場合は`default`プロファイルが使用される

#### 複数オプションの組み合わせ
```bash
./tools/get-s3-list.sh --bucket test --profile staging
```

### 使用例

```bash
# 例1: デフォルトプロファイルで全バケット取得
./tools/get-s3-list.sh

# 例2: 'backup'を含むバケットのみ取得
./tools/get-s3-list.sh --bucket backup

# 例3: productionプロファイルを使用
./tools/get-s3-list.sh --profile production

# 例4: stagingプロファイルで'test'を含むバケットを取得
./tools/get-s3-list.sh --bucket test --profile staging

# ヘルプの表示
./tools/get-s3-list.sh --help
```

### 出力例

```
プロファイル 'default' の確認中...
プロファイル 'default' の確認完了

S3バケット一覧を取得中...
フィルタ条件: バケット名に 'backup' を含む

=== S3バケット一覧 ===
- my-backup-bucket-2024
- data-backup-storage
- log-backup-archive

=== 結果サマリー ===
フィルタ条件に一致するバケット数: 3
使用プロファイル: default
```

### エラー対処

#### AWS CLIが見つからない場合
```
エラー: AWS CLIがインストールされていません
```
→ AWS CLIをインストールしてください

#### プロファイルが見つからない場合
```
警告: プロファイル 'xxx' が見つかりません
```
→ `aws configure --profile xxx` でプロファイルを設定してください

#### 認証エラーの場合
```
エラー: プロファイル 'xxx' でAWSにアクセスできません
```
→ 認証情報（アクセスキー等）を確認してください