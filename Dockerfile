# 使用官方的 Golang Docker 镜像作为基础镜像
FROM golang:1.16.5 AS builder

# 设置工作目录
WORKDIR /src

# 下载 Xray-Core 源代码
RUN git clone https://github.com/XTLS/Xray-core .

# 编译 Xray-Core 可执行程序
RUN go mod tidy && go build -v -tags=jsoniter

# 使用官方的 Debian Docker 镜像作为部署镜像
FROM debian:10.9

# 安装必要的运行时库
RUN apt-get update && apt-get install -y ca-certificates

# 从 builder 镜像中将编译好的可执行程序复制到部署镜像中
COPY --from=builder /src/xray /usr/local/bin

# 复制 Xray 配置文件
COPY config.json /etc/xray/config.json

# 设置工作目录
WORKDIR /

# 运行 Xray-Core
ENTRYPOINT ["/usr/local/bin/xray", "-config", "/etc/xray/config.json"]
