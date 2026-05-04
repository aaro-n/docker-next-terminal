# 阶段 1: 获取 Next Terminal 资源
FROM dushixiang/next-terminal:latest AS source

# 阶段 2: 最终运行镜像
FROM dushixiang/guacd:latest

# 设置工作目录
WORKDIR /usr/local/next-terminal

# 从 source 镜像中复制所有必要文件
# 注意：v3.2.0 需要 next-terminal 二进制文件、bin 目录和 web 目录
COPY --from=source /usr/local/next-terminal/next-terminal ./
COPY --from=source /usr/local/next-terminal/bin ./bin
COPY --from=source /usr/local/next-terminal/web ./web

# 环境变量设置
ENV NT_IN_CONTAINER=true
ENV TZ=Asia/Shanghai

# 安装 s6 控制器和基础工具
RUN apk add --no-cache s6 tzdata logrotate && \
    mkdir -p /etc/next-terminal && \
    # 配置时区
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone

# 复制启动脚本配置
COPY config/s6 /etc/s6
COPY config/start-run /var/run

# 设置权限 (核心点)
# 1. 确保 s6 脚本可执行
# 2. 确保主程序和 bin 下的网关程序有执行权限
RUN chmod -R +x /etc/s6 && \
    chmod +x /var/run/*.sh && \
    chmod +x /usr/local/next-terminal/next-terminal && \
    chmod -R +x /usr/local/next-terminal/bin

# 设置 s6 作为入口点
ENTRYPOINT ["s6-svscan", "/etc/s6"]
