FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y openssh-server curl python3 && \
    echo 'root:abc123' | chpasswd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    mkdir /run/sshd && \
    apt-get clean

# 安装 New-API
RUN curl -L -o /opt/new-api https://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.25/new-api-v1.0.0-rc.25 && \
    chmod +x /opt/new-api

# 安装 cloudflared
RUN curl -L -o /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x /usr/local/bin/cloudflared

# 安全代理脚本
COPY security_proxy.py /opt/security_proxy.py

# 启动脚本：安全代理(3000) -> New-API(3001)
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

EXPOSE 22 3000 3001
CMD ["/opt/start.sh"]
