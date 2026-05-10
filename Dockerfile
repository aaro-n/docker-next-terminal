# 声明变量，接收从 --build-arg 传来的版本号
ARG NT_VERSION=latest

# 阶段 1: 从原版镜像获取资源
FROM dushixiang/next-terminal:${NT_VERSION} AS source

# 阶段 2: 最终运行镜像 (使用 guacd 作为底包)
FROM dushixiang/guacd:latest

# 设置工作目录
WORKDIR /usr/local/next-terminal

# 从 source 镜像中复制必要文件
COPY --from=source /usr/local/next-terminal/next-terminal ./
COPY --from=source /usr/local/next-terminal/bin ./bin
COPY --from=source /usr/local/next-terminal/web ./web

# 环境变量设置
ENV NT_IN_CONTAINER=true
ENV TZ=Asia/Shanghai

# 安装 s6 控制器和基础工具
RUN apk add --no-cache s6 tzdata logrotate && \
    mkdir -p /etc/next-terminal && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone

# 复制启动脚本配置
COPY config/s6 /etc/s6
COPY config/start-run /var/run

# 设置权限
RUN chmod -R +x /etc/s6 && \
    chmod +x /var/run/*.sh && \
    chmod +x /usr/local/next-terminal/next-terminal && \
    chmod -R +x /usr/local/next-terminal/bin

# 使用 s6 启动服务
ENTRYPOINT ["s6-svscan", "/etc/s6"]
