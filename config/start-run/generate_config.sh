#!/bin/sh

# 默认配置文件输出路径
CONFIG_FILE="/etc/next-terminal/config.yaml"
TEMP_FILE="/tmp/next-terminal_config_generated.tmp"

# 防止重复执行
if [ -f "$TEMP_FILE" ]; then
    exit 0
fi
touch "$TEMP_FILE"

# 检查配置文件是否已存在
if [ -f "$CONFIG_FILE" ]; then
    echo "配置文件已存在: $CONFIG_FILE"
    exit 0
fi

# 函数：获取环境变量值，提供默认值
get_env() {
  var_name="$1"
  default_value="$2"
  eval value=\$"$var_name"
  echo "${value:-$default_value}"
}

# --- 核心逻辑：生成数据库配置 ---
generate_database_config() {
  DB_URL=$(get_env "APP_DATABASE_URL" "")
  
  echo "Database:"
  echo "  Enabled: $(get_env "APP_DATABASE_ENABLED" "true")"
  echo "  Type: postgres"
  
  if [ -n "$DB_URL" ]; then
    # 方案 A: 直接使用环境变量提供的完整 URL
    echo "  URL: \"$DB_URL\""
  else
    # 方案 B: 仅当 URL 为空时，使用分体参数
    cat <<EOF
  Postgres:
    Hostname: $(get_env "APP_DATABASE_POSTGRES_HOSTNAME" "postgresql")
    Port: $(get_env "APP_DATABASE_POSTGRES_PORT" "5432")
    Username: $(get_env "APP_DATABASE_POSTGRES_USERNAME" "next-terminal")
    Password: $(get_env "APP_DATABASE_POSTGRES_PASSWORD" "next-terminal")
    Database: $(get_env "APP_DATABASE_POSTGRES_DATABASE" "next-terminal")
EOF
  fi
  echo "  ShowSql: $(get_env "APP_DATABASE_SHOW_SQL" "false")"
}

# --- 开始生成完整配置文件 ---
{
  generate_database_config

  cat <<EOF

log:
  Level: $(get_env "APP_LOG_LEVEL" "debug")
  Filename: $(get_env "APP_LOG_FILENAME" "./logs/nt.log")

Server:
  Addr: "$(get_env "APP_SERVER_ADDR" "0.0.0.0:8088")"

App:
  Website:
    AccessLog: "$(get_env "APP_WEBSITE_ACCESS_LOG" "./logs/access.log")"
  Recording:
    Type: "$(get_env "APP_APP_RECORDING_TYPE" "local")"
    Path: "$(get_env "APP_APP_RECORDING_PATH" "/usr/local/next-terminal/data/recordings")"
  Guacd:
    Drive: "$(get_env "APP_APP_GUACD_DRIVE" "/usr/local/next-terminal/data/drive")"
    Hosts:
      - Hostname: $(get_env "APP_APP_GUACD_HOSTS_HOSTNAME" "guacd")
        Port: $(get_env "APP_APP_GUACD_HOSTS_PORT" "4822")
        Weight: $(get_env "APP_APP_GUACD_HOSTS_WEIGHT" "1")

  ReverseProxy:
    Enabled: $(get_env "APP_REVERSE_PROXY_ENABLED" "false")
    HttpEnabled: $(get_env "APP_REVERSE_PROXY_HTTP_ENABLED" "true")
    HttpAddr: "$(get_env "APP_REVERSE_PROXY_HTTP_ADDR" ":80")"
    HttpRedirectToHttps: $(get_env "APP_REVERSE_PROXY_HTTP_REDIRECT_TO_HTTPS" "false")
    HttpsEnabled: $(get_env "APP_REVERSE_PROXY_HTTPS_ENABLED" "true")
    HttpsAddr: "$(get_env "APP_REVERSE_PROXY_HTTPS_ADDR" ":443")"
    SelfProxyEnabled: $(get_env "APP_REVERSE_PROXY_SELF_PROXY_ENABLED" "true")
    SelfDomain: "$(get_env "APP_REVERSE_PROXY_SELF_DOMAIN" "nt.yourdomain.com")"
    Root: "$(get_env "APP_REVERSE_PROXY_ROOT" "")"
    IpExtractor: "$(get_env "APP_REVERSE_PROXY_IP_EXTRACTOR" "direct")"
    IpTrustList:
$(get_env "APP_REVERSE_PROXY_IP_TRUST_LIST" '      - "0.0.0.0/0"')
EOF
} > "$CONFIG_FILE"

echo "配置文件已生成: $CONFIG_FILE"
exit 0
