#!/bin/bash
# 延迟回滚脚本

# 参数
TIMEOUT=${1:-300}
BACKUP_FILE=$2

# 配置
CONFIG_DIR="$HOME/.openclaw"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"
LOG_FILE="$CONFIG_DIR/rollback.log"
HEARTBEAT_FILE="$CONFIG_DIR/.watchdog_heartbeat"

# 查找脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROLLBACK_CONFIG="$SCRIPT_DIR/rollback_config.sh"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "延迟回滚脚本启动，超时: ${TIMEOUT}秒，备份文件: $BACKUP_FILE"

# 创建心跳文件
touch "$HEARTBEAT_FILE"

# 等待超时
sleep "$TIMEOUT"

# 检查是否还需要回滚（心跳文件是否还在）
if [ ! -f "$HEARTBEAT_FILE" ]; then
    log "心跳文件已被删除，取消回滚"
    exit 0
fi

# 执行回滚
log "超时！开始执行回滚..."

if [ -f "$ROLLBACK_CONFIG" ]; then
    chmod +x "$ROLLBACK_CONFIG"
    "$ROLLBACK_CONFIG" "$BACKUP_FILE"
else
    log "错误：回滚脚本不存在: $ROLLBACK_CONFIG"
    # 简单回滚
    if [ -f "$BACKUP_FILE" ]; then
        cp "$BACKUP_FILE" "$CONFIG_FILE"
        log "配置已回滚到: $BACKUP_FILE"
        openclaw gateway restart
        log "OpenClaw 已重启"
    fi
fi

# 清理心跳文件
rm -f "$HEARTBEAT_FILE"

log "延迟回滚脚本结束"
