# 准备使用`dushixiang/next-terminal:latest`提取next-terminal二进制包
 FROM  dushixiang/next-terminal:latest AS builder1

# 使用`dushixiang/guacd:latest`作为基础镜像
 FROM  dushixiang/guacd:latest

# 设置默认环境变量
 ENV TZ Asia/Shanghai
 ENV DB sqlite
 ENV SQLITE_FILE './data/sqlite/next-terminal.db'
 ENV SERVER_PORT 8088
 ENV SERVER_ADDR 0.0.0.0:$SERVER_PORT
 ENV SSHD_PORT 8089
 ENV SSHD_ADDR 0.0.0.0:$SSHD_PORT
 ENV TIME_ZONE=Asia/Shanghai
 ENV GUACD_HOSTNAME 127.0.0.1
 ENV GUACD_PORT 4822

# 将从`dushixiang/next-terminal:latest`提取的二进制文件复制到`dushixiang/guacd:latest`中
 COPY --from=builder1 /usr/local/next-terminal /usr/local/next-terminal

# 安装supervisord，这部分我折腾好久
# 第二次修正，安装tzdata ，用于将VPS强制设置为北京时间
# 第三次修正，用于显示日志
 RUN apk add --no-cache logrotate tzdata supervisor

# 将supervisord配置文件复制到容器
 COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# 将镜像启动脚本复制到容器
 COPY config/docker-entrypoint.sh /var/docker-entrypoint.sh 
# 第三次修正，用于显示日志
 COPY config/logrotate.conf  /etc/logrotate.d/logrotate.conf
# 增加通过bash64解码方式添加hosts和SSH证书
 COPY config/start-config.sh /var/start-config.sh
 
# 为启动脚本设置运行权限并切将时间设置为北京时间
 RUN chmod +x /var/docker-entrypoint.sh && \
     chmod +x /var/start-config.sh && \
     cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
     echo 'Asia/Shanghai' > /etc/timezone

# 设置镜像运行时脚本路径
 ENTRYPOINT  /var/docker-entrypoint.sh

