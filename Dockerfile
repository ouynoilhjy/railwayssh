FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y openssh-server curl && \
    echo 'root:abc123' | chpasswd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    mkdir /run/sshd && \
    apt-get clean

# 安装 new-api
RUN curl -L -o /opt/new-api https://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.25/new-api-v1.0.0-rc.25 && \
    chmod +x /opt/new-api

# 启动脚本
RUN echo '#!/bin/bash\n/opt/new-api --port 3000 &\n/usr/sbin/sshd -D' > /opt/start.sh && \
    chmod +x /opt/start.sh

EXPOSE 22 3000
CMD ["/opt/start.sh"]
