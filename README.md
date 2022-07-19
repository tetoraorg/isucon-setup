# isucon-setup

## commands

| name               | description                                                                            |
| ------------------ | -------------------------------------------------------------------------------------- |
| bench-result       | スコアの推移をコミットする                                                             |
| exec-db            | `exec-db -e "<sql>"`でsqlを実行する                                                    |
| isu                | ログの移動、slow-on、nginx/mysql/appの再起動                                           |
| j                  | `sudo journalctl`のエイリアス                                                          |
| maji               | ログを全部切る                                                                         |
| restart-fluent-bit | fluent-bit(ダッシュボードにデータを送るやつ)の再起動。バックグラウンドで実行してくれる |
| s                  | `sudo systemctl`のエイリアス                                                           |
| slow-off           | slow-query-log切る                                                                     |
| slow-on            | slow-query-logつける                                                                   |
| start-pprof        | pprofの起動。ベンチ回してるときにつける                                                |
| sync-mysql         | mysql設定を同期する                                                                    |
| view-pprof         | 最新のpprofを見る                                                                      |

### setup

NOTE: 事前に<https://github.com/settings/tokens>からPersonal Access Tokenを作成しておく(このレポジトリのclone時に用いる)

```sh
PROJECT_ROOT=~/webapp
REPO_SSH_URL=git@github.com:tetoraorg/isucon12-qualify.git
APP_NAME=isuxxx
SERVICE_NAME=$APP_NAME.go.service
DASHBOARD_HOST=127.0.0.1
SERVER_ENV_PATH=~/env.sh
SERVER_NUMBER=01
```

2台目以降の設定がしやすいようにメンバーに上のスクリプトを投げる

```sh
sudo apt update -y && sudo apt upgrade -y && sudo apt install git -y
ssh-keygen && cat ~/.ssh/id_rsa.pub
```

公開鍵を問題レポジトリに登録している間に↓を動かす

```sh
git clone https://github.com/tetoraorg/isucon-setup.git /tmp/isucon-setup
cd /tmp/isucon-setup
make
```
