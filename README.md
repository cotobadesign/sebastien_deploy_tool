# Sebastien Deploy tool

## Setting
```shell
下記を設定してください
accountName='Your name'
password='Your password'
botId=Your bot id
projectId=
```

## アップロードしたいファイル名を引数で渡すと単体アップロード。引数を渡さないと同階層のAIMLを全てアップロードします。
```shell
uploadFileName.aiml
./put.sh uploadFileName
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
