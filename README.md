# imgurc.exe
コマンドラインから「imgur」等へ画像・ファイルの共有を行うCUIツール

author: @akatubame
/ date: 2015/03/15
/ version: 1.0
/ 使用言語: [AutoHotkey](http://ahkwiki.net/Top)

![screenshot]
[screenshot]: https://github.com/akatubame//blob/master/source/Screenshot.jpg "スクリーンショット"

##■本ソフトの説明

imgurなどの画像共有サービスへのアップロードをコマンドラインから扱うツールです。
Windows7で動作確認済み。

ブラウザへ画像をドラッグ＆ドロップする手間を軽減する目的で制作。
また、共有URLを標準出力で得ることができるのでプログラムの途中処理に組み込むこともできます。

主な機能は以下のとおり。

- [imgur](http://imgur.com/) への画像アップロード
- [transfer.sh](https://transfer.sh/) への任意のファイルのアップロード
- アップロードされたファイルのURLの取得（標準出力STDOUT）


##■使い方

コマンドプロンプトを起動して「imgurc.exe」にアクセスします。
本ツールでアップロードしたファイルのURLはプロンプトに表示されるので、[範囲選択] -> [コピー]でURLを取得することができます。

共有サービスの選択、画像ファイルの選択などはコマンドラインオプションにて行えます。

### コマンドラインオプション
imgurc.exe [-i or -t] ["FilePath"] ["ChangedFileName"]

- [-i or -t]
    - 共有サービスの選択。"-i"ならimgurを、"-t"ならtranser.shを使用します。
- ["FilePath"]
    - アップロードする画像orファイルのパスを指定します。（例："C:\sample.jpg"）
- ["ChangedFileName"]
    - transfer.sh専用のオプション。省略可。
    - URLに含まれるファイル名を変更できます。標準ならファイル名がそのままURLになります。

コマンドライン使用例：

> ; imgurで画像を共有する
> C:\> imgurc.exe "-i" "C:\sample.jpg"
> 
> ; transfer.shでテキストファイルを共有する
> C:\> imgurc.exe "-t" "C:\sample.txt" "https://transfer.sh/sample.txt"


##■終わりに  

imgurの画像共有APIには利用アプリケーション個別のClientIDが必要のため、標準では imgurc.exe の登録IDを使用しています。  
変更する場合は http://api.imgur.com/oauth2/addclient から適宜入手してください（※要ログイン）。  

その他、質問や機能の追加要望、バグ報告等は以下へどうぞ。

	Author: akatubame  
	Email: kurotubame5@gmail.com
