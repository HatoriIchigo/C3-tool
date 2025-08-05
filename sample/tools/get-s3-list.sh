#!/bin/bash

# AWS S3バケットリスト取得ツール
# 使用方法: ./get-s3-list.sh --bucket [バケット名の一部] --profile [プロファイル名]

# 初期値設定
BUCKET_FILTER=""
AWS_PROFILE="default"
HELP_FLAG=false

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --bucket)
            BUCKET_FILTER="$2"
            shift 2
            ;;
        --profile)
            AWS_PROFILE="$2"
            shift 2
            ;;
        --help|-h)
            HELP_FLAG=true
            shift
            ;;
        *)
            echo "不明なオプション: $1"
            echo "使用方法: $0 [--bucket バケット名の一部] [--profile プロファイル名] [--help]"
            exit 1
            ;;
    esac
done

# ヘルプ表示
if [ "$HELP_FLAG" = true ]; then
    echo "AWS S3バケットリスト取得ツール"
    echo ""
    echo "使用方法:"
    echo "  $0 [オプション]"
    echo ""
    echo "オプション:"
    echo "  --bucket NAME    指定した名前を含むバケットのみを表示"
    echo "  --profile NAME   使用するAWSプロファイル (デフォルト: default)"
    echo "  --help, -h       このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0                           # 全バケットを表示"
    echo "  $0 --bucket my-app           # 'my-app'を含むバケットのみ表示"
    echo "  $0 --profile prod            # prodプロファイルを使用"
    echo "  $0 --bucket test --profile dev # devプロファイルで'test'を含むバケットを表示"
    exit 0
fi

# AWS CLIの存在確認
if ! command -v aws &> /dev/null; then
    echo "エラー: AWS CLIがインストールされていません"
    echo "AWS CLIをインストールしてから再実行してください"
    exit 1
fi

# プロファイルの存在確認
echo "AWS プロファイル '$AWS_PROFILE' の確認中..."
if ! aws configure list --profile "$AWS_PROFILE" &> /dev/null; then
    echo "エラー: プロファイル '$AWS_PROFILE' が見つかりません"
    echo "利用可能なプロファイル:"
    aws configure list-profiles 2>/dev/null || echo "  (プロファイル情報を取得できませんでした)"
    exit 1
fi

# プロファイル設定の確認
if ! aws sts get-caller-identity --profile "$AWS_PROFILE" &> /dev/null; then
    echo "エラー: プロファイル '$AWS_PROFILE' での認証に失敗しました"
    echo "AWS認証情報を確認してください"
    exit 1
fi

echo "認証成功: プロファイル '$AWS_PROFILE' を使用します"

# S3バケットリストの取得
echo ""
echo "S3バケットリストを取得中..."

# バケットリストを取得
BUCKET_LIST=$(aws s3api list-buckets --profile "$AWS_PROFILE" --query 'Buckets[].Name' --output text 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "エラー: S3バケットリストの取得に失敗しました"
    exit 1
fi

if [ -z "$BUCKET_LIST" ]; then
    echo "S3バケットが見つかりませんでした"
    exit 0
fi

# フィルタリング処理
if [ -n "$BUCKET_FILTER" ]; then
    echo "フィルター: '$BUCKET_FILTER' を含むバケットのみ表示"
    echo ""
    FILTERED_LIST=$(echo "$BUCKET_LIST" | tr '\t' '\n' | grep "$BUCKET_FILTER")
    
    if [ -z "$FILTERED_LIST" ]; then
        echo "'$BUCKET_FILTER' を含むバケットは見つかりませんでした"
        exit 0
    fi
    
    BUCKET_LIST="$FILTERED_LIST"
else
    echo "全S3バケットを表示"
    echo ""
fi

# バケット情報の表示
BUCKET_COUNT=0
echo "バケット名                        作成日時                     リージョン"
echo "=================================================================="

for bucket in $(echo "$BUCKET_LIST" | tr '\t' '\n'); do
    # バケットの作成日時とリージョンを取得
    CREATION_DATE=$(aws s3api list-buckets --profile "$AWS_PROFILE" --query "Buckets[?Name=='$bucket'].CreationDate" --output text 2>/dev/null)
    REGION=$(aws s3api get-bucket-location --profile "$AWS_PROFILE" --bucket "$bucket" --query 'LocationConstraint' --output text 2>/dev/null)
    
    # リージョンがNoneまたは空の場合はap-northeast-1とする
    if [ "$REGION" = "None" ] || [ -z "$REGION" ]; then
        REGION="ap-northeast-1"
    fi
    
    # 作成日時のフォーマット調整
    if [ -n "$CREATION_DATE" ]; then
        FORMATTED_DATE=$(date -d "$CREATION_DATE" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$CREATION_DATE")
    else
        FORMATTED_DATE="N/A"
    fi
    
    printf "%-30s %-25s %s\n" "$bucket" "$FORMATTED_DATE" "$REGION"
    BUCKET_COUNT=$((BUCKET_COUNT + 1))
done

echo ""
echo "合計 $BUCKET_COUNT 個のバケットが見つかりました"