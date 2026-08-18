FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y openssh-server curl && \
    echo 'root:abc123' | chpasswd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    mkdir /run/sshd && \
    apt-get clean

RUN curl -L -o /opt/new-api https://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.25/new-api-v1.0.0-rc.25 && \
    chmod +x /opt/new-api

CMD /opt/new-api --port ${PORT:-3000} & /usr/sbin/sshd -D
