# softether-docker

Server mode
--------

### 手動設定テスト

```
docker run -d --name softether-server -p 443:443/tcp -p 992:992/tcp -p 1194:1194/udp -p 5555:5555/tcp -p 500:500/udp -p 4500:4500/udp -p 1701:1701/udp --cap-add NET_ADMIN agarichan/softether
```

設定はvpncmdを使う`docker exec softether-server /root/vpncmd`  
もしくはGUIのクライアントマネージャーを使う(おすすめ)

### docker-compose
をつかってやる、接続先設定やNIC作成などの初期化用のスクリプトを内部で実行する  
再起動後は設定が残るのでスクリプト実行は不要

`server/docker-compose.yml`で晒すポートや設定保存場所を設定する
`server/init.sh`の変数や処理をいい感じに変更し以下を実行する 

```
cd server
docker-compose up -d
docker cp init.sh $(docker-compose ps -q):/root/init.sh
docker-compose exec server sh init.sh
```

Client mode
--------

### 手動設定テスト  
vpncmdを使って手動で設定を追加する

```
docker run -d --name softether-client --privileged --net host --device /dev/net/tun agarichan/softehter client
docker exec softehter-client /root/vpncmd localhost /CLIENT
```

### docker-compose
を使って起動し、接続先設定やNIC作成などの初期化用のスクリプトを内部で実行する  
再起動後は設定が残るのでスクリプト実行は不要

`server/docker-compose.yml`で設定保存場所を設定する
`client/init.sh`の変数や処理をいい感じに変更し以下を実行する 

```
cd client
docker-compose up -d
docker cp init.sh $(docker-compose ps -q):/root/init.sh
docker-compose exec client sh init.sh
```

再起動後、NICにIPを割り当てる必要があるが自動化するために以下の環境変数が使用できる  
`CLIENT_IP`: IP/prefix (例えば10.8.0.1/24) 設定しない場合dhclientで取得を試みる  
`CLIENT_NICNAME`: 初期化時に作成したNICの名前を設定する。初期値はvpn0
