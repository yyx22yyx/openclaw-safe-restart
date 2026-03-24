#!/bin/bash
# 配置回滚脚本

# 参数
BACKUP_FILE=${1:-$(ls -t ~/.openclaw/openclaw.json.backup_* 2>/dev/null | head -1)}

# 配置
CONFIG_DIR="$HOME/.openclaw"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"
LOG_FILE="$CONFIG_DIR/rollback.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

log "开始执行配置回滚..."

# 检查备份文件
if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
    log "错误：未找到有效的备份文件"
    exit 1
fi

# 执行回滚
log "正在回滚配置到: $BACKUP_FILE"
cp "$BACKUP_FILE" "$CONFIG_FILE"

if [ $? -eq 0 ]; then
    log "配置回滚成功"
    
    # 重启 OpenClaw
    log "正在重启 OpenClaw..."
    openclaw gateway restart
    
    if [ $? -eq 0 ]; then
        log "OpenClaw 重启成功"
    else
        log "警告：OpenClaw 重启可能失败，请手动检查"
    fi
else
    log "错误：配置回滚失败"
    exit 1
fi

log "回滚操作完成"
