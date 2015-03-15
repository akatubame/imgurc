;-------------------------------------------
; その他自作関数ライブラリ
; by akatubame
;-------------------------------------------
;
;-------------------------------------------

; 指定文字列をコマンドプロンプトに標準出力
_Printf(str){
	FileEncoding, CP932
	
	; 出力の整形処理
	str = [%str%]
	StringTrimLeft, str, str, 1
	StringTrimRight, str, str, 1
	
	; 出力
	FileAppend, %str%, *
}
; 指定画像ファイルをtransfer.shへアップロード
_UploadImageToTransferSh(file, newName=""){
	
	; アップロード後のファイル名を整形。未指定なら元画像のファイル名を使用
	If (newName="") {
		newName := _FileGetName(file)
	}
	newName := _OptimizeNameUpl(newName)
	
	; 画像のバイナリデータを読込
	img := ComObjCreate("WIA.ImageFile")
	img.LoadFile(file)
	postdata := img.filedata.binarydata
	
	; 画像のアップロード
	WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WinHttpReq.Open("PUT", "https://transfer.sh/" newName)
	Try
		WinHttpReq.Send(postdata)
	Catch, e
		throw Exception(file "のアップロードに失敗しました：" e)
	
	; アップロード画像のURLを取得
	imgURL := WinHttpReq.ResponseText
	imgURL := RegExReplace(imgURL, "(?:\n|\r)$", "")
	
	return imgURL
}
; 指定画像ファイルをimgur.comへアップロード
_UploadImageToImgur(file){
	
	; 画像のバイナリデータを読込
	img := ComObjCreate("WIA.ImageFile")
	img.LoadFile(file)
	postdata := img.filedata.binarydata
	size := FileGetSize(file)
	
	; 画像のアップロード
	WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WinHttpReq.Open("POST", "https://api.imgur.com/3/upload")
	WinHttpReq.SetRequestHeader("Authorization", "Client-ID " A_ImgurClientID)
	WinHttpReq.SetRequestHeader("Content-Length", size)
	Try
		WinHttpReq.Send(postdata)
	Catch, e
		throw Exception(file "のアップロードに失敗しました：" e)
	
	; アップロード画像のURLを取得
	imgURL := WinHttpReq.ResponseText
	If (RegExMatch(imgURL, "i)""link"":""http:\\/\\/(.*?(jpg|jpeg|png|gif|apng|tiff|tif|bmp|pdf|xcf))""}", $))
		imgURL := "https://" RegExReplace($1, "\\/", "/")
	
	return imgURL
}
; パスからファイル名(拡張子付き)を取得
_FileGetName(path){
	SplitPath(path, name, dir, ext, noext, drive)
	return name
}
; 指定文字列からファイル名使用不可文字を削除する
_RemoveIllegalChar(str){
	;str := StringReplace(str, A_Space, "_", "All")
	;chars = ,<>:;'"/|\{}=+`%^&*~
	chars = ,<>:;"/|\{}=*~
	loop, parse, chars,
		str := StringReplace(str, A_LoopField, "", "All")
	;str := StringReplace(str, "_", A_Space, "All")
	return str
}
; 指定ファイル名をアップロードファイル名に適した文字列に整形する
_OptimizeNameUpl(str){
	str := _RegExEscapeZenkaku(str)
	str := _RemoveIllegalChar(str)
	return str
}
; 指定文字列から全角文字を消去
_RegExEscapeZenkaku(Target){
	return RegExReplace(Target, "[^\x20-\x7e]", "")
}
