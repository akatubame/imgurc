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
; 指定ファイルを指定URLへアップロード
_Http_FileUpload(method, file, uploadURL, setRequestHeader=""){
	
	; ファイルのデータを形式を自動判別して読込み
	postData := "", length := ""
	_FileReadBin(file, postData, length)
	
	; ファイルのアップロード
	WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WinHttpReq.open(method, uploadURL, false)
	WinHttpReq.setRequestHeader("Content-Length", length)
	For key,value in setRequestHeader {
		WinHttpReq.setRequestHeader(key, value)
	}
	
	Try
		WinHttpReq.send(postData)
	Catch, e
		throw Exception(file "のアップロードに失敗しました：" e)
	
	return WinHttpReq.responseText
}
; 指定ファイルをtransfer.shへアップロード
_UploadFileToTransferSh(file, newFileName=""){
	
	; アップロード後のファイル名を整形。未指定なら元のファイル名を使用
	If (newFileName="") {
		newFileName := _FileGetName(file)
	}
	newFileName := _OptimizeNameUpl(newFileName)
	
	; ファイルをアップロード、成功すればHTTPレスポンスからURLを取得
	uploadURL := _Http_FileUpload("PUT", file, "https://transfer.sh/" newFileName)
	uploadURL := RegExReplace(uploadURL, "(?:\n|\r)$", "") ; 末尾の改行除去
	
	return uploadURL
}
; 指定画像ファイルをimgur.comへアップロード
_UploadImageToImgur(file){
	
	; 画像をアップロード、成功すればHTTPレスポンスからURLを取得
	setRequestHeader := []
	setRequestHeader.Insert("Authorization", "Client-ID " A_ImgurClientID)
	uploadURL := _Http_FileUpload("POST", file, "https://api.imgur.com/3/upload", setRequestHeader)
	
	; アップロード画像のURLを整形
	If (RegExMatch(uploadURL, "i)""link"":""http:\\/\\/(.*?(jpg|jpeg|png|gif|apng|tiff|tif|bmp|pdf|xcf))""}", $))
		uploadURL := "https://" RegExReplace($1, "\\/", "/")
	
	return uploadURL
}
; パスからファイル名(拡張子付き)を取得
_FileGetName(path){
	SplitPath(path, name, dir, ext, noext, drive)
	return name
}
; 指定ファイルがバイナリ形式かアスキー形式かを判別する
_isBinFile(path, tolerance=5) {
	file := FileOpen(path, "r")
	loop, %tolerance% {
		file.RawRead(a, 1)
		byte := NumGet(&a, "Char")
		if (byte<9) or (byte>126) or ( (byte<32) and (byte>13) ) {
			file.Close()
			return 1
		}
	}
	file.Close()
	return 0
}
; 指定ファイルの形式を自動で判別して読込み
_FileReadBin(path, ByRef data, ByRef nLen){
	stream := ComObjCreate("ADODB.Stream")
	stream.Open()
	stream.Type := _isBinFile(path) ? 1 : 2
	stream.LoadFromFile(path)
	
	nLen := stream.Size
	data := _isBinFile(path) ? stream.Read(nLen) : stream.ReadText(nLen)
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
	chars = +`%&()[]
	loop, parse, chars,
		str := StringReplace(str, A_LoopField, "", "All")
	str := StringReplace(str, " ", "")
	return str
}
; 指定文字列から全角文字を消去
_RegExEscapeZenkaku(Target){
	return RegExReplace(Target, "[^\x20-\x7e]", "")
}
