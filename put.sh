#!/bin/bash

#登録済みのアカウント情報
accountName='Your name'
password='Your password'

#bot情報
botId=
projectId=

###設定ここまで###

#管理ツールの証明書に問題があるため,CURLに-kオプションをつける
export SSL_CERT_FILE=""

url=https://52.198.170.34:10443/management/v2.2

#ログイン
tmp=`curl -k -H "Content-type: application/json" -X POST -d '{"accountName":"'$accountName'","password":"'$password'"}' $url/login`

#アクセストークンを整形
accesstoken=`echo ${tmp} | sed -e s/{\"accessToken\"/Authorization/g -e s/\"NLP/NLP/g -e s/\"}//g`

upload(){
	uploadFile=$1

	#アップロード
	curl -k -F "uploadFile=@$uploadFile" -X PUT -H "$accesstoken" $url/projects/$projectId/bots/$botId/aiml

	#コンパイル
	curl -k -X POST -H "$accesstoken" $url/projects/$projectId/bots/$botId/scenarios/compile

	while :
	do
		#状況確認
		tmp=`curl -k -X GET -H "$accesstoken" $url/projects/$projectId/bots/$botId/scenarios/compile/status`
		statusNow=`echo ${tmp} | sed -e s/{\"status\":\"//g`
		FLAG=${statusNow:0:8}
		if [ $FLAG = Complete ]; then
			echo "Compile OK"
			#コンパイル終了していれば転送
			curl -k -X POST -H "$accesstoken" $url/projects/$projectId/bots/$botId/scenarios/transfer > /dev/null
			break
		else
			#コンパイル終了していなければ1秒後に再度実行
			echo "Compile NG"
		sleep 1
	fi
	done
}

if [ $1 ]; then
	#引数でファイル名がある場合、単体アップロード
	fileName=$1.aiml
	upload $fileName
else
	#引数がない場合、同階層のAIMLファイル全てをアップロード
	find . -name '*.aiml' > fileList
	fileName=./fileList
	while read line
	do
		#アップロード実行
		upload $line
	done < $fileName
fi

#ログアウト
curl -k -X GET -H "$accesstoken" $url/logout
