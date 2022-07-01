#!/bin/bash

GOLANG_VERSION=1.18.3
MEMBERS=(tesso57 toshi-pono Ras96)

echoe() {
  echo -e "\e[44m$1\e[m"
}

# read args
read -p "project root (ex. /home/isucon/webapp) > " PROJECT_ROOT
read -p "project repo url (ex. git@github.com:hoge/isuconXXq.git) > " PROJECT_REPO_URL
read -p "app name (ex. isucondition) > " APP_NAME
read -p "service name (ex. isucondition.go.service) > " SERVICE_NAME

# add environment variables to ~/.bashrc
echoe "Adding environment variables to ~/.bashrc"
echo "export PROJECT_ROOT=$PROJECT_ROOT" >> ~/.bashrc
echo "export PROJECT_REPO_URL=$PROJECT_REPO_URL" >> ~/.bashrc
echo "export APP_NAME=$APP_NAME" >> ~/.bashrc
echo "export SERVICE_NAME=$SERVICE_NAME" >> ~/.bashrc
source ~/.bashrc

# install apt tools
echoe "Installing apt tools..."
sudo apt install -y build-essential percona-toolkit htop git curl wget vim
echoe "Done!!"

# Add commands to $PATH
echoe "Adding commands for isucon..."
sudo cp /tmp/isucon-setup/bin/* /usr/local/bin
echoe "Done!!"

# install asdf
echoe "Installing asdf..."
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
echo "source ~/.asdf/asdf.sh" >> ~/.bashrc
echo "source ~/.asdf/completions/asdf.bash" >> ~/.bashrc
source ~/.bashrc
echoe "Done!!"

# install golang
echoe "Installing golang..."
if ! type asdf >/dev/null 2>&1; then
  PATH=$HOME/.asdf/bin:$PATH
fi
asdf plugin add golang
asdf install golang $GOLANG_VERSION
asdf global golang $GOLANG_VERSION
echoe "Done!!"

# install fluent-bit
# TODO: https://github.com/fluent/fluent-bit/issues/5628
echoe "Installing fluent-bit..."
if [ "$(cat /etc/issue | awk '{print $2}')" == "22.04" ]; then
  git clone --depth 1 git@github.com:fluent/fluent-bit.git /tmp/fluent-bit
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

# run fluent-bit as a daemon
echoe "Running fluent-bit as a daemon"
git clone --depth 1 git@github.com:tetoraorg/isucon-dashboard.git /tmp/isucon-dashboard
sudo mkdir -p /usr/local/etc/fluent-bit
sudo cp /tmp/isucon-dashboard/client/fluent-bit/* /usr/local/etc/fluent-bit
start-fluent-bit
echoe "Done!!"

# sync public keys
echoe "Syncing public keys..."
mkdir -p ~/.ssh
for member in ${MEMBERS[@]}; do
  curl https://github.com/$member.keys >> ~/.ssh/authorized_keys
done
echoe "Done!!"

# initialize git
echoe "Initializing git..."
git config --global user.name "server"
git config --global user.email "example@gmail.com"
git config --global core.editor "vim"
git config --global push.default current
git config --global init.defaultbranch main
cd $PROJECT_ROOT \
  && git init \
  && git remote add origin $PROJECT_REPO_URL
echoe "Done!!"
echoe "Please push your code to Github."

source ~/.bashrc
