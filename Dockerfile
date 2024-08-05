FROM dushixiang/next-terminal:latest AS builder1
FROM dushixiang/guacd:latest

ENV TZ Asia/Shanghai
ENV DB sqlite
ENV SQLITE_FILE '/usr/local/next-terminal/data/sqlite/next-terminal.db'
ENV SERVER_PORT 8088
ENV SERVER_ADDR 0.0.0.0:$SERVER_PORT
ENV SSHD_PORT 8089
ENV SSHD_ADDR 0.0.0.0:$SSHD_PORT
ENV TIME_ZONE=Asia/Shanghai
ENV GUACD_PORT 4822

COPY --from=builder1 /usr/local/next-terminal /usr/local/next-terminal

# 安装 runit 和其他必要的工具
RUN apk add --no-cache runit tzdata logrotate

# 创建服务目录
RUN mkdir -p /etc/service/next-terminal /etc/service/next-guacd /etc/service/start-config

# 复制服务脚本
COPY config/next-terminal.sh /etc/service/next-terminal/run
COPY config/next-guacd.sh /etc/service/next-guacd/run
COPY config/start-run.sh /etc/service/start-config/run

COPY config/runit /etc/runit

COPY config/start-config.sh /var/start-config.sh

# 设置脚本权限
RUN chmod +x /etc/service/*/run && \
    chmod +x /var/start-config.sh && \
    chmod +x /etc/runit/* && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone

# 设置镜像的入口点
ENTRYPOINT ["/sbin/runit"]
