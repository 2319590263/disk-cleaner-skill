# Disk Cleaner Skill for OpenClaw

![OpenClaw Skill](https://img.shields.io/badge/OpenClaw-Skill-blue)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

一个功能强大的Windows磁盘清理和优化工具，专为OpenClaw设计。提供全面的磁盘分析、安全清理和系统维护功能。

## ✨ 功能特性

### 📊 磁盘分析
- **实时状态监控**：检查C盘和D盘使用情况
- **健康度评估**：自动评估磁盘健康状态
- **大文件检测**：查找占用空间的大文件
- **重复文件扫描**：识别重复文件节省空间

### 🗑️ 安全清理
- **临时文件清理**：系统临时文件、日志文件等
- **浏览器缓存清理**：Edge、Chrome、Firefox缓存
- **Windows更新缓存**：清理更新下载文件
- **回收站管理**：安全清空回收站
- **下载文件夹优化**：清理30天前的下载文件

### ⚙️ 系统维护
- **磁盘错误检查**：检测并建议修复磁盘错误
- **碎片整理建议**：分析是否需要碎片整理
- **应用缓存清理**：清理应用程序缓存文件
- **定期维护计划**：支持计划任务自动清理

### 🔒 安全特性
- ✅ 危险操作前请求确认
- ✅ 系统文件和用户文档保护
- ✅ 模拟运行模式（预览清理效果）
- ✅ 操作日志记录和恢复机制
- ✅ 备份重要文件建议

## 🚀 快速开始

### 安装方法

#### 方法1：通过OpenClaw安装
```bash
# 从GitHub安装
openclaw skill install https://github.com/2319590263/disk-cleaner-skill.git

# 或从本地安装
openclaw skill install ./disk-cleaner
```

#### 方法2：手动安装
1. 克隆仓库到OpenClaw技能目录：
```bash
git clone https://github.com/2319590263/disk-cleaner-skill.git
```

2. 复制到OpenClaw技能目录：
```bash
# Windows
copy disk-cleaner-skill %USERPROFILE%\.openclaw\skills\
```

### 使用方法

#### 通过OpenClaw调用
```bash
# 运行完整清理流程
openclaw agent --skill disk-cleaner --message "清理电脑垃圾文件"

# 只检查不清理
openclaw agent --skill disk-cleaner --message "检查磁盘状态"

# 清理特定项目
openclaw agent --skill disk-cleaner --message "清理临时文件"
```

#### 直接使用PowerShell脚本
```powershell
# 进入技能目录
cd skills\disk-cleaner

# 分析磁盘状态
.\scripts\analyze.ps1 -Drive C

# 执行清理（需要确认）
.\scripts\cleaner.ps1 -Tasks temp,cache,downloads

# 模拟运行（预览效果）
.\scripts\cleaner.ps1 -Tasks temp,cache -DryRun
```

## 📁 项目结构

```
disk-cleaner/
├── README.md                    # 本文档
├── SKILL.md                     # OpenClaw技能说明
├── config.json                  # 配置文件
├── .gitignore                   # Git忽略文件
├── scripts/                     # PowerShell脚本
│   ├── analyze.ps1             # 磁盘分析脚本
│   ├── cleaner.ps1             # 清理执行脚本
│   └── utils.ps1               # 工具函数库
└── references/                  # 参考文档
    ├── checklist.md            # 清理检查清单
    ├── safety.md               # 安全操作指南
    └── examples.md             # 使用示例
```

## ⚙️ 配置说明

编辑 `config.json` 文件自定义设置：

```json
{
  "settings": {
    "defaultDrive": "C",
    "enableDeepScan": false,
    "maxFileAgeDays": 30,
    "safeMode": true,
    "backupBeforeClean": true
  },
  "cleanTasks": {
    "temp": { "enabled": true, "safe": true },
    "cache": { "enabled": true, "safe": true },
    "downloads": { "enabled": true, "safe": false },
    "recycle": { "enabled": true, "safe": false }
  }
}
```

## 🎯 使用场景

### 日常维护（每周）
- 清理临时文件和浏览器缓存
- 检查磁盘使用率
- 清空回收站

### 深度清理（每月）
- 清理Windows更新缓存
- 扫描重复文件
- 检查磁盘健康状态

### 紧急清理（空间不足时）
- 快速释放磁盘空间
- 清理大文件和旧文件
- 优化系统性能

## 🔧 高级功能

### 自定义清理规则
```powershell
# 创建自定义清理脚本
$customRules = @{
    "OldProjects" = {
        # 清理6个月前的项目备份
        Get-ChildItem "D:\Projects" -Filter "*.bak" -Recurse | 
            Where-Object {$_.LastWriteTime -lt (Get-Date).AddMonths(-6)} |
            Remove-Item -Force
    }
}
```

### 计划任务自动化
```powershell
# 创建每周清理计划任务
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-File `"C:\Scripts\weekly_clean.ps1`""

$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
Register-ScheduledTask -TaskName "WeeklyDiskCleanup" -Action $action -Trigger $trigger
```

### 集成到系统监控
```powershell
# 监控磁盘使用率，自动触发清理
$threshold = 80  # 警告阈值
$health = Get-DiskHealth -DriveLetter C

if ($health.UsedPercent -gt $threshold) {
    .\scripts\cleaner.ps1 -Tasks temp,cache -Confirm:$false
}
```

## 📋 清理检查清单

### 安全可清理项目（✅）
- 系统临时文件 (`%TEMP%`, `C:\Windows\Temp`)
- 浏览器缓存文件
- Windows更新缓存
- 30天前的日志文件

### 需要确认的项目（⚠️）
- 下载文件夹（30天前文件）
- 应用程序缓存
- 重复文件（相同内容）
- 大文件（显示详情）

### 危险项目（❌ 不建议清理）
- 系统文件 (`C:\Windows`, `C:\Program Files`)
- 用户文档和项目文件
- 应用程序数据文件
- 数据库和配置文件

## 🛡️ 安全指南

### 清理前准备
1. **备份重要数据**
2. **关闭所有应用程序**
3. **运行模拟模式预览**
4. **确认清理项目**

### 安全措施
- 系统文件和用户文档自动保护
- 危险操作前请求确认
- 支持操作撤销（回收站）
- 详细的清理日志

### 故障恢复
- 从回收站恢复误删文件
- 使用备份文件恢复
- 查看操作日志排查问题

## 📈 性能优化

### 清理效果
- **临时文件**：通常可释放 1-5 GB
- **浏览器缓存**：通常可释放 0.5-2 GB
- **Windows更新缓存**：通常可释放 2-10 GB
- **下载文件夹**：根据使用情况而定

### 系统影响
- **清理时间**：5-15分钟（取决于文件数量）
- **内存使用**：< 100 MB
- **CPU使用**：< 10%
- **网络影响**：无

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

### 报告问题
1. 在 [Issues](https://github.com/2319590263/disk-cleaner-skill/issues) 页面创建新问题
2. 描述问题现象和复现步骤
3. 提供系统信息和错误日志

### 提交代码
1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 开发要求
- 使用 PowerShell 5.1+ 编写脚本
- 遵循安全编码规范
- 添加详细的注释和文档
- 包含测试用例

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

感谢以下项目和工具：
- [OpenClaw](https://openclaw.ai) - 开源AI助手平台
- [PowerShell](https://docs.microsoft.com/powershell) - 强大的脚本语言
- [GitHub](https://github.com) - 代码托管和协作平台

## 📞 支持与联系

- **问题反馈**：[GitHub Issues](https://github.com/2319590263/disk-cleaner-skill/issues)
- **功能建议**：[Discussions](https://github.com/2319590263/disk-cleaner-skill/discussions)
- **文档更新**：提交 Pull Request

---

**⭐ 如果这个项目对你有帮助，请给个Star！**

**🔄 定期更新，关注仓库获取最新版本**

**🔧 安全第一，谨慎操作，定期备份**

*最后更新: 2026-04-18 | 版本: v1.0.0*