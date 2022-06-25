#!/bin/bash

GOLANG_VERSION=1.18.3
MEMBERS=(tesso57 toshi-pono Ras96)

echoe() {
  echo -e "\e[44m$1\e[m"
}

# read args
read -p "project root (ex. /home/isucon/webapp) > " PROJECT_ROOT
read -p "project repo url (ex. git@github.com:hoge/isuconXXq.git) > " PROJECT_REPO_URL

# update & upgrade apt packages
echoe "Updating & upgrading apt packages..."
apt update -y
apt upgrade -y
echoe "Done!!"

# install apt tools
echoe "Installing apt tools..."
apt install -y build-essential percona-toolkit htop git curl wget sudo vim
echoe "Done!!"

# clone git repositories
echoe "Cloning git repositories..."
git clone git@github.com:fluent/fluent-bit.git /tmp/fluent-bit
git clone git@github.com:Ras96/isucon-dashboard.git /tmp/isucon-dashboard
git clone git@github.com:Ras96/isucon-setup.git /tmp/isucon-setup
echoe "Done!!"

# Add commands to $PATH
echoe "Adding commands for isucon..."
mv /tmp/isucon-setup/bin/* /usr/local/bin
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
echoe "Installing fluent-bit..."
cd /tmp/fluent-bit/build
cmake ../ -DFLB_CONFIG_YAML=Off
make mv /tmp/fluent-bit/bin/* /usr/local/bin
echoe "Done!!"

# run fluent-bit as a daemon
echoe "Running fluent-bit as a daemon"
mkdir -p /etc/fluent-bit
mv /tmp/isucon-dashboard/client/fluent-bit/* /etc/fluent-bit
restart-fluent-bit
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
