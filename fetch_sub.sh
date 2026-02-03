
#下载所有节点 -> 按照关键词排序 -> 逐个测试延迟 -> 选出最快且符合优先级的一个节点 -> 生成配置文件 -> 重启 v2ray 服务
#优先级顺序：新加坡 > 日本 > 台湾 > 香港 > 美国
#延迟阈值：300 ms
#扫描时间：600 s
#如果所有优先级节点均不达标，则选取延迟最低的节点

#补充：
#1. TG机器人通知接口：xxx 端口  2026.02.03

#!/bin/bash
# v2ray-proxy/fetch_sub.sh
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

SCRIPT_VERSION="4.2-Full-Env-Logic"
SUB_URL="${V2RAY_SUBSCRIPTION_URL}"
OUTPUT_FILE="/etc/v2ray/config.json"
LATENCY_THRESHOLD=300

# 从环境变量获取通知地址，如果为空则不通知
NOTIFY_URL="${INTERNAL_NOTIFY_URL}"

# 优先级顺序
PRIORITY_KEYWORDS=("新加坡|SG|Singapore" "日本|JP|Japan" "台湾|TW|Taiwan" "香港|HK|HongKong" "美国|US|America")

safe_decode() {
    local input=$(echo "$1" | tr -d '[:space:]' | tr '_-' '/+')
    local len=${#input}; local pad=$(( (4 - len % 4) % 4 ))
    if [ $pad -gt 0 ]; then for ((i=0; i<$pad; i++)); do input="${input}="; done; fi
    echo "$input" | base64 -d 2>/dev/null
}

test_latency() {
    local addr=$1; local port=$2
    local start=$(date +%s%N)
    if nc -z -w 2 "$addr" "$port" > /dev/null 2>&1; then
        local end=$(date +%s%N)
        echo $(( (end - start) / 1000000 ))
    else
        echo 9999
    fi
}

do_update() {
    echo "========== $(date): 执行智能切换策略 =========="
    RAW_B64=$(curl -sL -A "Mozilla/5.0" "$SUB_URL" | tr -d '[:space:]')
    [ -z "$RAW_B64" ] && return 1
    DECODED_LIST=$(safe_decode "$RAW_B64")
    echo "$DECODED_LIST" | grep "vmess://" > /tmp/all_nodes.txt
    
    SELECTED_VMESS=""
    for kw in "${PRIORITY_KEYWORDS[@]}"; do
        while read -r line; do
            VMESS_RAW=$(echo "$line" | sed 's/vmess:\/\///')
            NODE_JSON=$(safe_decode "$VMESS_RAW")
            NODE_NAME=$(echo "$NODE_JSON" | jq -r '.ps // ""')
            if echo "$NODE_NAME" | grep -Ei "$kw" > /dev/null; then
                ADD=$(echo "$NODE_JSON" | jq -r '.add'); PORT=$(echo "$NODE_JSON" | jq -r '.port')
                L=$(test_latency "$ADD" "$PORT")
                if [ "$L" -lt "$LATENCY_THRESHOLD" ]; then
                    SELECTED_VMESS="$NODE_JSON"; SELECTED_NAME="$NODE_NAME"; SELECTED_LATENCY="$L"
                    break 2
                fi
            fi
        done < /tmp/all_nodes.txt
    done

    if [ -n "$SELECTED_VMESS" ]; then
        write_config "$SELECTED_VMESS"
        # 使用环境变量中的 URL 发送通知
        if [ -n "$NOTIFY_URL" ]; then
            curl -s -X POST "$NOTIFY_URL" -d "msg=✅ 节点已自动切换%0A📍 节点：$SELECTED_NAME%0A⚡ 延迟：${SELECTED_LATENCY}ms" > /dev/null
        fi
        pkill -HUP v2ray || true
    fi
}

write_config() {
    local JSON=$1
    ADD=$(echo "$JSON" | jq -r '.add'); PORT=$(echo "$JSON" | jq -r '.port')
    UUID=$(echo "$JSON" | jq -r '.id'); NET=$(echo "$JSON" | jq -r '.net // "tcp"')
    PATH_VAL=$(echo "$JSON" | jq -r '.path // ""'); TLS=$(echo "$JSON" | jq -r '.tls // ""')
    cat > "$OUTPUT_FILE" <<EOF
{
  "inbounds": [{"port": 10808, "listen": "0.0.0.0", "protocol": "socks", "settings": {"auth": "noauth", "udp": true}}],
  "outbounds": [{
    "protocol": "vmess",
    "settings": {"vnext": [{"address": "$ADD", "port": $PORT, "users": [{"id": "$UUID", "alterId": 0, "security": "auto"}]}]},
    "streamSettings": {"network": "$NET", "security": "$TLS", "$(echo $NET)Settings": {"path": "$PATH_VAL"}}
  }]
}
EOF
}

while true; do
    if [ ! -f "$OUTPUT_FILE" ]; then do_update; else
        CUR_ADDR=$(jq -r '.outbounds[0].settings.vnext[0].address' "$OUTPUT_FILE")
        CUR_PORT=$(jq -r '.outbounds[0].settings.vnext[0].port' "$OUTPUT_FILE")
        L=$(test_latency "$CUR_ADDR" "$CUR_PORT")
        [ "$L" -gt "$LATENCY_THRESHOLD" ] && do_update
    fi
    sleep 600
done