# Sebastien Deploy tool

## Setting
```shell
下記を設定してください
accountName='Your name'
password='Your password'
uploadFile=Sample.aiml
botId=Your bot id
projectId=
```

## アップロードしたいファイル名とボット名を引数で渡すことも出来ます。アップロードしたいaimlファイルは同階層に置いて下さい。
```shell
uploadFile=$1.aiml
botId=$2
```

## projectIDがわからない場合は下記を実行してください。
JSONパーサーをインストール
```shell
brew install jq
tmp=`curl -k -X GET -H "$accesstoken" $url/projects`
projectId=`echo ${tmp} | jq .projects[].projectId`
echo $projectId
exit
```
