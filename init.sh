#!/bin/bash

set -e

GOLANG_VERSION=latest
MEMBERS=(tesso57 toshi-pono Ras96)
SETUP_REPO_DIR=/tmp/isucon-setup

echoe() {
  echo -e "\e[44m$1\e[m"
}

source ~/.bashrc
if [ -z "$PROJECT_ROOT" ]; then
  echo "environment variables are not defined"
  exit 1
fi

# aptからインストール
echoe "Installing apt tools..."
sudo apt install -y build-essential percona-toolkit htop git curl wget vim graphviz
echoe "Done!!"

# このレポジトリから設定ファイルをコピー
echoe "Copying commands and configuration files..."
if [ -d $PROJECT_ROOT/.git/logs ]; then
  echoe "Skiped!! (project's git repository already exists)"
elif [ -d $SETUP_REPO_DIR ]; then
  cp -r $SETUP_REPO_DIR/bin $PROJECT_ROOT
  cp -r $SETUP_REPO_DIR/fluent-bit $PROJECT_ROOT
  fconf=$PROJECT_ROOT/fluent-bit/fluent-bit.conf
  cat $fconf | sed -e "s/\${DASHBOARD_HOST}/$DASHBOARD_HOST/" | tee $fconf > /dev/null
else
  echo "Please clone the repository first."
  exit 1
fi
echoe "Done!!"

# env.shにシンボリックリンクを貼る
# 既にあったらエラーを吐いて終了する
echoe "Linking env file..."
mv $SERVER_ENV_PATH $PROJECT_ROOT/isu$SERVER_NUMBER/
ln -s $PROJECT_ROOT/isu$SERVER_NUMBER/env.sh $SERVER_ENV_PATH
echoe "Done!!"

# 用意した諸コマンドをPATHに追加
echoe "Adding commands for isucon..."
echo "export PATH=$PROJECT_ROOT/bin:\$PATH" >> ~/.bashrc
echoe "Done!!"

# asdfをインストール
echoe "Installing asdf..."
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
echo "source ~/.asdf/asdf.sh" >> ~/.bashrc
echo "source ~/.asdf/completions/asdf.bash" >> ~/.bashrc
source ~/.bashrc
echoe "Done!!"

# asdfからgoをインストール
echoe "Installing golang..."
if ! type asdf >/dev/null 2>&1; then
  PATH=$HOME/.asdf/bin:$PATH
fi
asdf plugin add golang
asdf install golang $GOLANG_VERSION
asdf global golang $GOLANG_VERSION
echoe "Done!!"

# aptかソースからfluent-bitをインストール
# TODO: https://github.com/fluent/fluent-bit/issues/5628
echoe "Installing fluent-bit..."
if [ "$(cat /etc/issue | awk '{print $2}')" == "22.04" ]; then
  git clone --depth 1 https://github.com/fluent/fluent-bit.git /tmp/fluent-bit
  cd /tmp/fluent-bit/build
  cmake ../ -DFLB_CONFIG_YAML=Off
  make
  sudo cp /tmp/fluent-bit/build/bin/fluent-bit /usr/local/bin
else
  sudo apt install -y cmake flex bison
  curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh
  sudo cp /opt/fluent-bit/bin/fluent-bit /usr/local/bin
fi
echoe "Done!!"

# fluent-bitを常時動かす
echoe "Running fluent-bit as a daemon"
sudo rm -rf /etc/fluent-bit
sudo ln -sf $PROJECT_ROOT/fluent-bit /etc
restart-fluent-bit
echoe "Done!!"

# 公開鍵を登録
echoe "Syncing public keys..."
mkdir -p ~/.ssh
for member in ${MEMBERS[@]}; do
  curl https://github.com/$member.keys >> ~/.ssh/authorized_keys
done
echoe "Done!!"

# Gitの設定
echoe "Initializing git..."
git config --global user.name "server"
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git config --global core.editor "vim"
git config --global push.default current
git config --global init.defaultbranch main
cd $PROJECT_ROOT \
  && git init \
  && git remote add origin $PROJECT_REPO_URL
echoe "Done!!"
echoe "Please push your code to Github."

# 最後に設定ファイルを読み込む
source ~/.bashrc
