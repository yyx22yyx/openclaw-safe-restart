---
name: openclaw-safe-restart
description: OpenClaw 安全重启技能，提供配置自动回滚功能。当使用 `safe_restart` 命令重启 OpenClaw 时，会自动备份配置并在超时后回滚；手动重启（`openclaw gateway restart`）不触发回滚。
---

# OpenClaw 安全重启技能

## 功能说明

这个技能提供 OpenClaw 的安全重启机制，防止配置错误导致无法恢复：

- **安全重启**：备份配置 → 重启 → 超时自动回滚
- **手动重启**：使用原生命令不触发回滚机制
- **可配置超时**：默认 5 分钟，可自定义

## 什么时候使用

当你需要修改 `openclaw.json` 配置并重启时，使用 `safe_restart` 命令：

```bash
safe_restart [超时秒数]
```

## 使用方法

### 1. 安全重启（带自动回滚）

```bash
# 使用默认 5 分钟超时
safe_restart

# 自定义超时时间（秒）
safe_restart 120  # 2 分钟后回滚
```

### 2. 手动重启（不回滚）

```bash
# 正常重启，不触发回滚机制
openclaw gateway restart
```

## 工作原理

1. **备份配置**：自动备份当前 `openclaw.json` 到带时间戳的备份文件
2. **启动回滚脚本**：后台运行延迟回滚脚本
3. **重启 OpenClaw**：执行 `openclaw gateway restart`
4. **超时回滚**：如果超时时间内没有手动取消，自动回滚配置并重启

## 取消回滚

如果重启成功，想取消自动回滚：

```bash
# 找到回滚脚本进程
ps aux | grep delayed_rollback

# 杀掉进程
kill <PID>
```

或者直接删除心跳文件：

```bash
rm ~/.openclaw/.watchdog_heartbeat
```

## 脚本文件

- `scripts/safe_restart.sh` - 主入口脚本
- `scripts/delayed_rollback.sh` - 延迟回滚脚本
- `scripts/rollback_config.sh` - 配置回滚脚本

## 日志文件

- `~/.openclaw/safe_restart.log` - 安全重启日志
- `~/.openclaw/rollback.log` - 回滚操作日志

## 配置文件位置

- **Linux/macOS**: `~/.openclaw/openclaw.json`
- **Windows**: `%USERPROFILE%\.openclaw\openclaw.json`

## 最佳实践

1. 修改配置前先用 `safe_restart` 测试
2. 确认一切正常后记得取消回滚
3. 定期检查备份文件，清理旧备份
4. 生产环境建议使用较短的超时时间（2-3 分钟）
