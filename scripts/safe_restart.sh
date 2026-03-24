#!/bin/bash
# OpenClaw 安全重启脚本 - 主入口

# 配置
CONFIG_DIR="$HOME/.openclaw"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"
LOG_FILE="$CONFIG_DIR/safe_restart.log"

# 默认超时时间（秒）
DEFAULT_TIMEOUT=300
TIMEOUT=${1:-$DEFAULT_TIMEOUT}

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    log "错误：配置文件不存在: $CONFIG_FILE"
    exit 1
fi

# 1. 备份配置
BACKUP_FILE="$CONFIG_FILE.backup_$(date +%Y%m%d_%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
log "配置已备份到: $BACKUP_FILE"

# 2. 查找脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DELAYED_ROLLBACK="$SCRIPT_DIR/delayed_rollback.sh"

if [ ! -f "$DELAYED_ROLLBACK" ]; then
    log "错误：延迟回滚脚本不存在: $DELAYED_ROLLBACK"
    exit 1
fi

# 3. 启动延迟回滚脚本（后台运行）
chmod +x "$DELAYED_ROLLBACK"
"$DELAYED_ROLLBACK" "$TIMEOUT" "$BACKUP_FILE" &
ROLLBACK_PID=$!
log "延迟回滚脚本已启动 (PID: $ROLLBACK_PID), 超时: ${TIMEOUT}秒"

# 4. 重启 OpenClaw
log "正在重启 OpenClaw..."
openclaw gateway restart

log "安全重启完成！如果 ${TIMEOUT} 秒内未取消回滚，将自动恢复配置"
log "取消回滚命令: kill $ROLLBACK_PID"
