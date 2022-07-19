#!/bin/bash

set -aeux

SETUP_REPO_DIR=/tmp/isucon-setup
GOLANG_VERSION=latest
MEMBERS=(tesso57 toshi-pono Ras96)

# 環境変数が設定されてなかったら終了
echo "PROJECT_ROOT=$PROJECT_ROOT" >> ~/.bashrc
echo "REPO_SSH_URL=$REPO_SSH_URL" >> ~/.bashrc
echo "APP_NAME=$APP_NAME" >> ~/.bashrc
echo "SERVICE_NAME=$SERVICE_NAME" >> ~/.bashrc
echo "DASHBOARD_HOST=$DASHBOARD_HOST" >> ~/.bashrc
echo "SERVER_ENV_PATH=$SERVER_ENV_PATH" >> ~/.bashrc
echo "SERVER_NUMBER=$SERVER_NUMBER" >> ~/.bashrc

# aptからインストール
sudo apt install -y build-essential percona-toolkit htop git curl wget vim graphviz cmake flex bison

# 公開鍵を登録
mkdir -p ~/.ssh
for member in ${MEMBERS[@]}; do
  curl https://github.com/$member.keys >> ~/.ssh/authorized_keys
done

# Gitの設定
git config --global user.name "server"
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git config --global core.editor "vim"
git config --global push.default current
git config --global init.defaultbranch main
git config --global fetch.prune=true
git config --global alias.lo "log --oneline"
cd $PROJECT_ROOT
git init
git branch -M main
git remote add origin $REPO_SSH_URL
git fetch origin
git reset --hard origin/main

# このレポジトリから設定ファイルをコピー
if [ -d $PROJECT_ROOT/.git/logs ]; then
  echo "Skiped!! (project's git repository already exists)"
elif [ -d $SETUP_REPO_DIR ]; then
  cp -r $SETUP_REPO_DIR/bin $PROJECT_ROOT
  cp -r $SETUP_REPO_DIR/fluent-bit $PROJECT_ROOT
  fconf=$PROJECT_ROOT/fluent-bit/fluent-bit.conf
  cat $fconf | sed -e "s/\${DASHBOARD_HOST}/$DASHBOARD_HOST/" > $fconf
else
  echo "Please clone the repository first."
  exit 1
fi

# 用意した諸コマンドをPATHに追加
echo "export PATH=$PROJECT_ROOT/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc

# env.sh,.bashrcにシンボリックリンクを貼る
confdir=$PROJECT_ROOT/isu$SERVER_NUMBER
mkdir -p $confdir
[ ! -L $SERVER_ENV_PATH ] && mv $SERVER_ENV_PATH $confdir
ln -sf $confdir/env.sh $SERVER_ENV_PATH
[ ! -L ~/.bashrc ] && mv ~/.bashrc $confdir
ln -sf $confdir/.bashrc ~/.bashrc

# asdfをインストール
if [ ! -d ~/.asdf ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf
  echo "source ~/.asdf/asdf.sh" >> ~/.bashrc
  echo "source ~/.asdf/completions/asdf.bash" >> ~/.bashrc
  source ~/.bashrc

  # asdfからgoをインストール
  asdf plugin add golang
  asdf install golang $GOLANG_VERSION
  asdf global golang $GOLANG_VERSION
fi

# aptかソースからfluent-bitをインストール
# TODO: https://github.com/fluent/fluent-bit/issues/5628
if [ "$(cat /etc/issue | awk '{print $2}')" == "22.04" ]; then
  [ !d /tmp/fluent-bit ] && git clone --depth 1 https://github.com/fluent/fluent-bit.git /tmp/fluent-bit
  cd /tmp/fluent-bit/build
  cmake ../ -DFLB_CONFIG_YAML=Off
  make
  sudo cp /tmp/fluent-bit/build/bin/fluent-bit /usr/local/bin
else
  curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
  sudo cp /opt/fluent-bit/bin/fluent-bit /usr/local/bin
fi

# fluent-bitを常時動かす
sudo rm -rf /etc/fluent-bit
sudo ln -sf $PROJECT_ROOT/fluent-bit /etc
restart-fluent-bit

# 最後に設定ファイルを読み込む
source ~/.bashrc

echo "Done!!! (Push diff to github)"
