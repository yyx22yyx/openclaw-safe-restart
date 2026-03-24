# OpenClaw Safe Restart

OpenClaw 安全重启技能，提供配置自动回滚功能，防止配置错误导致无法恢复。

## 功能特性

- 🔒 **安全重启**：自动备份配置，超时后自动回滚
- ⚡ **手动重启**：原生命令不触发回滚机制
- ⏱️ **可配置超时**：默认 5 分钟，支持自定义
- 📝 **详细日志**：完整记录重启和回滚操作
- 💾 **自动备份**：带时间戳的配置备份文件

## 什么时候使用

当你需要修改 `openclaw.json` 配置并重启 OpenClaw 时，使用 `safe_restart` 命令可以：
- 防止配置错误导致无法回复消息
- 自动回滚到上一个稳定版本
- 无需手动备份和恢复

## 安装

### 方法一：作为 OpenClaw Skill 使用

1. 将整个 `openclaw-safe-restart` 目录复制到你的 OpenClaw skills 目录：
   ```bash
   cp -r openclaw-safe-restart ~/.openclaw/workspace/skills/
   ```

2. 给脚本添加执行权限：
   ```bash
   chmod +x ~/.openclaw/workspace/skills/openclaw-safe-restart/scripts/*.sh
   ```

### 方法二：独立使用

直接克隆或下载脚本即可使用。

## 使用方法

### 1. 安全重启（推荐）

使用默认 5 分钟超时：
```bash
~/.openclaw/workspace/skills/openclaw-safe-restart/scripts/safe_restart.sh
```

自定义超时时间（秒）：
```bash
# 2 分钟后回滚
~/.openclaw/workspace/skills/openclaw-safe-restart/scripts/safe_restart.sh 120
```

### 2. 手动重启（不回滚）

使用原生命令，不触发回滚机制：
```bash
openclaw gateway restart
```

### 3. 取消回滚

如果重启成功，想取消自动回滚：

**方法一：删除心跳文件**
```bash
rm ~/.openclaw/.watchdog_heartbeat
```

**方法二：杀掉回滚进程**
```bash
# 找到回滚脚本进程
ps aux | grep delayed_rollback

# 杀掉进程
kill <PID>
```

## 工作原理

```
1. 备份配置 → 2. 启动回滚脚本（后台）→ 3. 重启 OpenClaw 
                                      ↓
                           4. 超时未取消 → 自动回滚配置并重启
```

1. **备份配置**：自动备份当前 `openclaw.json` 到带时间戳的备份文件
2. **启动回滚脚本**：后台运行延迟回滚脚本
3. **重启 OpenClaw**：执行 `openclaw gateway restart`
4. **超时回滚**：如果超时时间内没有手动取消，自动回滚配置并重启

## 文件说明

```
openclaw-safe-restart/
├── SKILL.md                          # OpenClaw Skill 说明文档
├── README.md                         # GitHub 项目说明（本文件）
└── scripts/
    ├── safe_restart.sh               # 主入口脚本
    ├── delayed_rollback.sh           # 延迟回滚脚本
    └── rollback_config.sh            # 配置回滚脚本
```

## 日志文件

- `~/.openclaw/safe_restart.log` - 安全重启日志
- `~/.openclaw/rollback.log` - 回滚操作日志

## 配置文件位置

- **Linux/macOS**: `~/.openclaw/openclaw.json`
- **Windows**: `%USERPROFILE%\.openclaw\openclaw.json`

## 最佳实践

1. ✅ 修改配置前先用 `safe_restart` 测试
2. ✅ 确认一切正常后记得取消回滚
3. ✅ 定期检查备份文件，清理旧备份
4. ✅ 生产环境建议使用较短的超时时间（2-3 分钟）
5. ⚠️ 不要在 `safe_restart` 执行期间手动修改配置

## 示例场景

### 场景一：修改 API Key
```bash
# 1. 修改 openclaw.json 中的 API Key
# 2. 使用安全重启
~/.openclaw/workspace/skills/openclaw-safe-restart/scripts/safe_restart.sh

# 3. 测试是否能正常回复消息
# 4. 如果正常，取消回滚
rm ~/.openclaw/.watchdog_heartbeat
```

### 场景二：修改模型配置
```bash
# 1. 修改模型配置
# 2. 使用 2 分钟超时
~/.openclaw/workspace/skills/openclaw-safe-restart/scripts/safe_restart.sh 120

# 3. 等待 2 分钟，如果没取消会自动回滚
```

## 常见问题

**Q: 超时时间设置多久合适？**
A: 建议 2-5 分钟，根据你的测试速度调整。

**Q: 如何查看回滚日志？**
A: 查看 `~/.openclaw/rollback.log` 文件。

**Q: 可以手动回滚吗？**
A: 可以，直接运行 `rollback_config.sh` 脚本。

**Q: 备份文件会自动清理吗？**
A: 不会，建议定期手动清理旧的备份文件。

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 相关链接

- [OpenClaw 官网](https://openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [OpenClaw 文档](https://docs.openclaw.ai)
