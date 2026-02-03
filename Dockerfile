# v2ray-proxy/Dockerfile
FROM alpine:latest

# 安装基础运行环境和网络测试工具
RUN apk update && \
    apk add --no-cache bash curl jq coreutils ca-certificates unzip procps netcat-openbsd

# 拷贝并安装 V2Ray (确保文件名与目录下的 zip 一致)
COPY v2ray-linux-64.zip /tmp/v2ray-linux-64.zip
RUN unzip /tmp/v2ray-linux-64.zip -d /tmp/v2ray_files && \
    mv /tmp/v2ray_files/v2ray /usr/bin/v2ray && \
    chmod +x /usr/bin/v2ray && \
    rm -rf /tmp/v2ray-linux-64.zip /tmp/v2ray_files

RUN mkdir -p /etc/v2ray /var/log/v2ray
WORKDIR /etc/v2ray