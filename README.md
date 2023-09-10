# 说明
具体使用请参考`docker-compose-example.yml`和官方文档，环境变量请参考官方文档。
# 构建原因
只是对next-terminal提的问题的整理，[连接](https://github.com/dushixiang/next-terminal/issues/401)

# 更新记录
2023.09.11 新增两个变量`HOSTS_CONFIG`和`SSH_AUTHORIZED_KEYS`，内容都经过base64编码后得到的。
           `HOSTS_CONFIG`转码前例子
```
# Next Terminal运行服务
   44.33.22.111     mariadb.service.app
.......
```
             `SSH_AUTHORIZED_KEYS`转码前
```
-----BEGIN OPENSSH PRIVATE KEY-----
aaaasssssssssssss......
-----END OPENSSH PRIVATE KEY-----
```
这两个变量已经经过测试，可以正常使用 。
