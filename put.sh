#!/bin/bash

#登録済みのアカウント情報
accountName='Your name'
password='Your password'

#アップロードしたいファイル名とボット名を引数で渡す
#uploadFile=$1.aiml
#botId=$2
#固定の場合はこちら
uploadFile=Sample.aiml
botId=Your bot id

projectId=
#projectIDがわからない場合
#JSONパーサーをインストール
#brew install jq
#tmp=`curl -k -X GET -H "$accesstoken" $url/projects`
#projectId=`echo ${tmp} | jq .projects[].projectId`
#echo $projectId
#exit

#管理ツールの証明書に問題があるため,CURLに-kオプションをつける
export SSL_CERT_FILE=""

###設定ここまで###

url=https://52.198.170.34:10443/management/v2.2

#ログイン
tmp=`curl -k -H "Content-type: application/json" -X POST -d '{"accountName":"'$accountName'","password":"'$password'"}' $url/login`

#アクセストークンを整形
accesstoken=`echo ${tmp} | sed -e s/{\"accessToken\"/Authorization/g -e s/\"NLP/NLP/g -e s/\"}//g`

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
		echo "OK"
		#コンパイル終了していれば転送
		curl -k -X POST -H "$accesstoken" $url/projects/$projectId/bots/$botId/scenarios/transfer > /dev/null
		break
	else
		#コンパイル終了していなければ1秒後に再度実行
		echo "NG"
		sleep 1
	fi
done

#ログアウト
curl -k -X GET -H "$accesstoken" $url/logout
