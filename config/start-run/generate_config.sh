#!/bin/sh

# 默认配置文件输出路径
CONFIG_FILE="/etc/next-terminal/config.yaml"

# 临时文件路径
TEMP_FILE="/tmp/next-terminal_config_generated.tmp"

# 检查临时文件是否存在
if [ -f "$TEMP_FILE" ]; then
    exit 0
fi

# 创建临时文件，表示配置文件将要生成
touch "$TEMP_FILE"

# 检查配置文件是否已存在
if [ -f "$CONFIG_FILE" ]; then
    echo "配置文件已存在: $CONFIG_FILE"
    exit 0
fi

# 设置默认的数据库类型
APP_DATABASE_TYPE="${APP_DATABASE_TYPE:-sqlite}"

# 函数：获取环境变量值，提供默认值
get_env() {
  var_name="$1"
  default_value="$2"
  eval value=\$"$var_name"
  echo "${value:-$default_value}"
}

# 函数：生成数据库配置
generate_database_config() {
  case "$APP_DATABASE_TYPE" in
    sqlite)
      cat <<EOF
  sqlite:
    path: $(get_env "APP_DATABASE_SQLITE_PATH" "/usr/local/next-terminal/data/sqlite/next-terminal.db")
EOF
      ;;
    mysql)
      cat <<EOF
  mysql:
    hostname: $(get_env "APP_DATABASE_MYSQL_HOSTNAME" "localhost")
    port: $(get_env "APP_DATABASE_MYSQL_PORT" "3306")
    username: $(get_env "APP_DATABASE_MYSQL_USERNAME" "next-terminal")
    password: $(get_env "APP_DATABASE_MYSQL_PASSWORD" "next-terminal")
    database: $(get_env "APP_DATABASE_MYSQL_DATABASE" "next-terminal")
EOF
      ;;
    postgres)
      cat <<EOF
  postgres:
    hostname: $(get_env "APP_DATABASE_POSTGRES_HOSTNAME" "localhost")
    port: $(get_env "APP_DATABASE_POSTGRES_PORT" "5432")
    username: $(get_env "APP_DATABASE_POSTGRES_USERNAME" "next-terminal")
    password: $(get_env "APP_DATABASE_POSTGRES_PASSWORD" "next-terminal")
    database: $(get_env "APP_DATABASE_POSTGRES_DATABASE" "next-terminal")
EOF
      ;;
    *)
      exit 1  # 不支持的数据库类型，直接退出
      ;;
  esac
}

# 开始生成配置文件
{
  cat <<EOF
database:
  enabled: $(get_env "APP_DATABASE_ENABLED" "true")
  type: $APP_DATABASE_TYPE
$(generate_database_config)
  ShowSql: false

log:
  level: $(get_env "APP_LOG_LEVEL" "debug")
  filename: $(get_env "APP_LOG_FILENAME" "/usr/local/next-terminal/data/logs/nt.log")

server:
  addr: "$(get_env "APP_SERVER_ADDR" "0.0.0.0:8088")"
  tls:
    enabled: $(get_env "APP_SERVER_TLS_ENABLED" "false")
    auto: $(get_env "APP_SERVER_TLS_AUTO" "false")
    cert: $(get_env "APP_SERVER_TLS_CERT" "/usr/local/next-terminal//data/cert/localhost.pem")
    key: $(get_env "APP_SERVER_TLS_KEY" "/usr/local/next-terminal/data/cert/localhost-key.pem")

app:
  website:
    accessLog: "/usr/local/next-terminal/data/logs/access.log"
  recording:
    type: $(get_env "APP_APP_RECORDING_TYPE" "local")
    path: $(get_env "APP_APP_RECORDING_PATH" "/usr/local/next-terminal/data/recordings")
  s3:
    endpoint: "$(get_env "APP_S3_ENDPOINT" "127.0.0.1:9000")"
    accessKeyId: "$(get_env "APP_S3_ACCESS_KEY_ID" "minioadmin")"
    secretAccessKey: "$(get_env "APP_S3_SECRET_ACCESS_KEY" "miniopassword")"
    bucket: "$(get_env "APP_S3_BUCKET" "recording")"
    useSSL: $(get_env "APP_S3_USE_SSL" "false")
  guacd:
    drive: $(get_env "APP_APP_GUACD_DRIVE" "/usr/local/next-terminal/data/drive")
    hosts:
      - hostname: $(get_env "APP_APP_GUACD_HOSTS_HOSTNAME" "guacd")
        port: $(get_env "APP_APP_GUACD_HOSTS_PORT" "4822")
        weight: $(get_env "APP_APP_GUACD_HOSTS_WEIGHT" "1")

  ReverseProxy:
    Enabled: $(get_env "APP_REVERSE_PROXY_ENABLED" "false")
    HttpEnabled: $(get_env "APP_REVERSE_PROXY_HTTP_ENABLED" "true")
    HttpAddr: "$(get_env "APP_REVERSE_PROXY_HTTP_ADDR" ":80")"
    HttpRedirectToHttps: $(get_env "APP_REVERSE_PROXY_HTTP_REDIRECT" "false")
    HttpsEnabled: $(get_env "APP_REVERSE_PROXY_HTTPS_ENABLED" "true")
    HttpsAddr: "$(get_env "APP_REVERSE_PROXY_HTTPS_ADDR" ":443")"
    SelfProxyEnabled: $(get_env "APP_REVERSE_PROXY_SELF_ENABLED" "true")
    SelfDomain: "$(get_env "APP_REVERSE_PROXY_SELF_DOMAIN" "nt.yourdomain.com")"
    Root: "$(get_env "APP_REVERSE_PROXY_ROOT" "")"
    IpExtractor: "$(get_env "APP_REVERSE_PROXY_IP_EXTRACTOR" "direct")"
    IpTrustList:
      - "$(get_env "APP_REVERSE_PROXY_IP_TRUST_LIST" "0.0.0.0/0")"
EOF
} > "$CONFIG_FILE"

# 仅在成功生成配置文件时输出提示
echo "配置文件已生成: $CONFIG_FILE"

# 生成完配置文件后退出
exit 0
