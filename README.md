# C3-tool
Claude Codeのカスタムコマンドを利用して、メモ書きから簡単なツールを作成する。

## 概要
Claude Codeのカスタムコマンドを利用して、メモ書きから簡単なツール 及び 使い方を作成します。

## 手順
1. noteディレクトリにツールの概要、ツールにしてほしい処理を書く。
    - 詳細はsample/note/note.mdを参照してください。
2. Claude カスタムコマンド`/CREATE-tool-script`でツールを作成する。
    - 作成されたコマンドは、toolsディレクトリに出力されます。
3. Claude カスタムコマンド`/CREATE-tool-usage`でツールの使い方を作成する。
    - 作成されたドキュメントは docs/usage.md に保存される。

## ディレクトリ構成
```
-  .claude
|   L commands
|      |- CREATE-tool-script.md : ツール（プログラム）を作成するカスタムコマンド
|      L  CREATE-tool-usage.md : ツールの使い方のドキュメントを作成するカスタムコマンド
|- docs
|   L  usage.md : ツールの使い方を説明したファイルが作成される
|- note
|   L  ★ツールの概要を書いたファイルをここに配置（ファイル名指定なし）★
|- tools
|   L  作成されたプログラムはここに配置される
L  CLAUDE.md : プロジェクト全体を通して Claude に設定するファイル
```