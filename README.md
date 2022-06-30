# isucon-setup

```sh
apt update -y && apt upgrade -y && apt install git -y
ssh-keygen && cat ~/.ssh/id_rsa.pub
# and register the public key to github
```

```sh
# after registration
git clone git@github.com:tetoraorg/isucon-setup.git /tmp/isucon-setup
cd /tmp/isucon-setup
./init.sh
```
