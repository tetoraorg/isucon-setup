#!/bin/bash

GOLANG_VERSION=1.18.3
MEMBERS=(tesso57 toshi-pono Ras96)

# read args
read -p "project root (ex. /home/isucon/webapp) > " PROJECT_ROOT
read -p "project repo url (ex. git@github.com:hoge/isuconXXq.git) > " PROJECT_REPO_URL

# update & upgrade apt packages
echo "Updating & upgrading apt packages..."
sudo apt update -y
sudo apt upgrade -y
echo "Done!!"

# install apt tools
echo "Installing apt tools..."
sudo apt install -y percona-toolkit htop git curl wget
echo "Done!!"

# install asdf
echo "Installing asdf..."
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
echo "source ~/.asdf/asdf.sh" >> ~/.bashrc
echo "source ~/.asdf/completions/asdf.bash" >> ~/.bashrc
source ~/.bashrc
echo "Done!!"

# install golang
echo "Installing golang..."
asdf plugin add golang
asdf install golang $GOLANG_VERSION
asdf global golang $GOLANG_VERSION
echo "Done!!"

# Add commands to $PATH
echo "Adding commands to $PATH..."
echo "export PATH=$PATH:$PWD/bin" >> ~/.bashrc
source ~/.bashrc
echo "Done!!"

# sync public keys
echo "Syncing public keys..."
mkdir -p ~/.ssh
for member in ${MEMBERS[@]}; do
  curl https://github.com/$member.keys >> ~/.ssh/authorized_keys
done
echo "Done!!"

# initialize git
echo "Initializing git..."
git config --global user.name "server"
git config --global user.email "example@gmail.com"
git config --global core.editor "vim"
git config --global push.default current
git config --global init.defaultbranch main
cd $PROJECT_ROOT \
  && git init \
  && git remote add origin $PROJECT_REPO_URL
echo "Done!!"
echo "Please push your code to Github."
