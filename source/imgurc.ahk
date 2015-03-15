;#Persistent
#SingleInstance, Force
#NoTrayIcon

#Include <CommonHeader>

;------------------------------------------------------------------------;
; imgurc.exe - imgur等の共有サービスをコマンドで行うCUIツール -
;------------------------------------------------------------------------;
;    v1.0 Released by akatubame
;------------------------------------------------------------------------;

;------------------------------------------------------------------------;
; 初期設定
;------------------------------------------------------------------------;

; imgur APIキーの設定
EnvSet, A_ImgurClientID, d126ca2764a1d42

;【説明】
;  imgurの画像共有APIを利用するには利用アプリケーション個別のClientIDが必要です。
;  標準では imgurc.exe の登録IDを使用します。
;  変更する場合は http://api.imgur.com/oauth2/addclient から入手してください。（※要ログイン）

;------------------------------------------------------------------------;
; 処理開始
;------------------------------------------------------------------------;

; 引数の取得
args := A_Init_Object["CmdArgs"]

; アップロードする画像が存在しなければエラー
file := args[2]
If ( !FileExist(file) ) {
	ErrorAndExit("Not Found File: " file)
}

; 第一引数の値でアップロードするサービスを選択
;   [-i] = imgur.com
;   [-t] = transfer.sh
server := args[1]

; imgur.comで画像の共有
If (server == "-i") {
	url  := _UploadImageToImgur(file)
}
; transfer.shで各種ファイルの共有
Else If (server == "-t") {
	file    := args[2]
	newName := args[3]
	url     := _UploadImageToTransferSh(file, newName)
}
Else {
	ErrorAndExit("Unknown Server: " server "`n" "Please Input ""-i"" or ""-t""")
}

; アップロードされたファイルのURLが正しく取得されていなければエラー
regex := "http(s)?://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)?"
If ( !RegExMatch(url, regex) )
	ErrorAndExit("File Upload Failed: " file)

; URLが正しければ標準出力にURLを出力して終了
stdout := url
_Printf(stdout)
ExitApp

;-------------------------------------------
; 関数
;-------------------------------------------

; エラー時の処理
ErrorAndExit(message){
	message := "ERROR!!" "`n" message
	_Printf(message)
	ExitApp
}