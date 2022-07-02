# isucon-setup

## commands

|name|description|
|-|-|
|exec-db|`exec-db -e "<sql>"`でsqlを実行する|
|jo|`journalctl -u $SERVICE_NAME -xef`|
|restart-isu|ログの移動、slow-on、nginx/mysql/appの再起動|
|slow-off|slow-query-log切る|
|slow-on|slow-query-logつける|
|start-fluent-bit|fluent-bit(ダッシュボードにデータを送るやつ)の起動。バックグラウンドで実行してくれる|
|start-pprof|pprofの起動。ベンチ回してるときにつける|

### setup

```sh
echo "export PROJECT_ROOT=hoge" >> ~/.bashrc
echo "export PROJECT_REPO_URL=hoge" >> ~/.bashrc
echo "export APP_NAME=hoge" >> ~/.bashrc
echo "export SERVICE_NAME=hoge" >> ~/.bashrc
echo "export DASHBOARD_HOST=hoge" >> ~/.bashrc
```

2台目以降の設定がしやすいようにメンバーに上のスクリプトを投げる

```sh
sudo apt update -y && sudo apt upgrade -y && sudo apt install git -y
ssh-keygen && cat ~/.ssh/id_rsa.pub
# and register the public key to github
```

```sh
# after registration

git clone git@github.com:tetoraorg/isucon-setup.git /tmp/isucon-setup
cd /tmp/isucon-setup
./init.sh

# or
sudo apt install curl -y
curl -s https://raw.githubusercontent.com/tetoraorg/isucon-setup/main/init.sh?token=hoge | bash
```
