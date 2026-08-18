#!/bin/bash
# 启动 New-API (端口3001)
/opt/new-api --port 3001 &
sleep 3
# 启动安全代理 (端口3000)
python3 /opt/security_proxy.py &
# 启动 SSH
/usr/sbin/sshd -D
