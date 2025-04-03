#!/bin/sh

# 定义临时文件的路径
TEMP_FILE="/tmp/my_script_run.lock"

# 检查临时文件是否存在
if [ -f "$TEMP_FILE" ]; then
    exit 0
fi

touch "$TEMP_FILE"

# 调用 start-config.sh 和 generate_config.sh
exec /bin/sh -c '/var/run/start-config.sh && /var/run/generate_config.sh && echo "配置文件和HOSTS配置已经生成。"'
