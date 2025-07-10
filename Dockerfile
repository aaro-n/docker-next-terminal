# Dockerfile

FROM dushixiang/next-terminal:latest AS builder1
FROM dushixiang/guacd:latest

COPY --from=builder1 /usr/local/next-terminal /usr/local/next-terminal


# 安装 runit 和其他必要的工具
RUN apk add --no-cache s6 tzdata logrotate && \
    mkdir -p /etc/next-terminal


COPY config/s6 /etc/s6

COPY config/start-run /var/run

# 设置脚本权限
RUN chmod -R +x /etc/s6 && \
    chmod -R 755 /etc/s6  && \ 
    chmod +x /var/run/*.sh  && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone  && \
    chmod -R 555 /usr/local/next-terminal/next-terminal

# 设置 s6 作为入口点
ENTRYPOINT ["s6-svscan", "/etc/s6"]
