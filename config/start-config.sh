#!/usr/bin/env sh

# 解密HOSTS_CONFIG并写入/etc/hosts文件
echo "$HOSTS_CONFIG" | base64 -d >> /etc/hosts

# 创建文件夹 
mkdir -p /root/.ssh

# 解密SSH_AUTHORIZED_KEYS并写入/root/.ssh/id_rsa文件
echo "$SSH_AUTHORIZED_KEYS" | base64 -d >> /root/.ssh/id_rsa

# 设置权限
chmod 700 /root/.ssh
chmod 600 /root/.ssh/id_rsa
