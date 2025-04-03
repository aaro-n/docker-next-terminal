#!/usr/bin/env sh

# 临时文件路径
TEMP_FILE="/tmp/start-config.tmp"

# 检查临时文件是否存在
if [ -f "$TEMP_FILE" ]; then
    exit 0
fi

# 创建临时文件，表示配置将要生成
touch "$TEMP_FILE"
if [ $? -ne 0 ]; then
    exit 1
fi

# 检查环境变量 HOSTS_CONFIG 是否存在
if [ -n "$HOSTS_CONFIG" ]; then
    # 将 HOSTS_CONFIG 拆分成行并替换换行符为分号
    HOSTS_CONFIG=$(echo "$HOSTS_CONFIG" | tr '\n' ';')

    # 清空 /etc/hosts 中的旧条目（可选）
    # cp /etc/hosts /etc/hosts.bak
    # echo "127.0.0.1 localhost" > /etc/hosts

    # 添加新条目
    echo "$HOSTS_CONFIG" | tr ';' '\n' | while IFS= read -r HOST_ENTRY; do
        echo "$HOST_ENTRY" >> /etc/hosts
    done
fi

# 检查特定文件是否存在
SPECIFIC_FILE="/usr/local/next-terminal/hosts"  # 替换为您的特定文件路径
if [ -f "$SPECIFIC_FILE" ]; then
    # 将特定文件的内容复制到 /etc/hosts
    cat "$SPECIFIC_FILE" >> /etc/hosts
fi

# 追加 guacd 条目
echo "127.0.0.1 guacd" >> /etc/hosts

echo "已配置HOSTS"

exit 0
