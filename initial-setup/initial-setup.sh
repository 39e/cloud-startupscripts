#!/bin/bash
# CentOS 7.x の初期設定をします
# - パッケージの最新化
# - suコマンドの制限
#   - suコマンドの実行可能ユーザ・グループを限定する
#   - パスワード入力なしでsudoコマンドを利用可能にする
# - ssh接続の制限
#   - rootユーザのsshログインを禁止する
#   - 公開鍵認証のみ接続を許可する

yum clean all
yum -y update


# allow only members of the wheel group to use 'su'
cp /etc/pam.d/su /etc/pam.d/su.bak
## uncomment 'auth required pam_wheel.so use_uid'
tac /etc/pam.d/su > /etc/pam.d/su.tmp
cat << EOS >> /etc/pam.d/su.tmp 2>&1
auth required pam_wheel.so use_uid
EOS
tac /etc/pam.d/su.tmp > /etc/pam.d/su
rm -rf /etc/pam.d/su.tmp

## restrict the use of 'su' command
cp /etc/login.defs /etc/login.defs.bak
cat << EOS >> /etc/login.defs
SU_WHEEL_ONLY yes
EOS

## 'sudo' command without password
cp /etc/sudoers /etc/sudoers.bak
cat << EOS >> /etc/sudoers 2>&1
%wheel ALL=(ALL) NOPASSWD: ALL
EOS


# disallow SSH login and add public_key
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
cat << EOS >> /etc/ssh/sshd_config 2>&1
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
AuthorizedKeysFile .ssh/authorized_keys
EOS

# sshd service restart
systemctl restart sshd
