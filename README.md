# isucon-setup

## commands

|name|description|
|-|-|
|bench-result|スコアの推移をコミットする|
|exec-db|`exec-db -e "<sql>"`でsqlを実行する|
|isu|ログの移動、slow-on、nginx/mysql/appの再起動|
|j|`sudo journalctl`のエイリアス|
|maji|ログを全部切る|
|restart-fluent-bit|fluent-bit(ダッシュボードにデータを送るやつ)の再起動。バックグラウンドで実行してくれる|
|s|`sudo systemctl`のエイリアス|
|slow-off|slow-query-log切る|
|slow-on|slow-query-logつける|
|start-pprof|pprofの起動。ベンチ回してるときにつける|
|sync-mysql|mysql設定を同期する|
|view-pprof|最新のpprofを見る|

### setup

```sh
echo "export PROJECT_ROOT=hoge" >> ~/.bashrc
echo "export PROJECT_REPO_URL=hoge" >> ~/.bashrc
echo "export APP_NAME=hoge" >> ~/.bashrc
echo "export SERVICE_NAME=hoge" >> ~/.bashrc
echo "export DASHBOARD_HOST=hoge" >> ~/.bashrc
source ~/.bashrc
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
