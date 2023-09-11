# 说明
具体使用请参考`docker-compose-example.yml`和官方文档，环境变量请参考官方文档。
# 构建原因
只是对next-terminal提的问题的整理，[连接](https://github.com/dushixiang/next-terminal/issues/401)

# 更新记录
**2023.09.12** 已经测试在Fly.io上通过SSH方式登录next-terminal，next-terminal工作正常。注意，Fly.io现在提供的IPV4是共享的，只有私有IPV4可以使用SSH登录，分配的IPV6正常工作。

fly.toml中端口配置
```
# 使用8088端口作为网页访问端口
[http_service]
  internal_port = 8088
  end_port = 8090
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1
  processes = ["app"]

# 使用10010端口作为SSH登录端口，SSH内部端口为8089
[[services]]
  protocol = "tcp"
  internal_port = 8089

  [[services.ports]]
    port = 10010
  [services.concurrency]
    type = "connections"
    hard_limit = 100
    soft_limit = 90

  [[services.tcp_checks]]
    interval = "10s"
    timeout = "2s"
    grace_period = "1s"
    restart_limit = 0
```
**2023.09.11** 新增两个变量`HOSTS_CONFIG`和`SSH_AUTHORIZED_KEYS`，内容都经过base64编码后得到的。

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
