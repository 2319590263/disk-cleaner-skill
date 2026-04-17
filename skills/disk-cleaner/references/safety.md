# 安全操作指南

## 核心安全原则

### 1. 不删除系统文件
- ❌ 不删除 Windows 目录下的任何文件
- ❌ 不删除 Program Files 目录下的应用程序
- ❌ 不删除系统驱动文件 (.sys, .dll)
- ❌ 不删除注册表文件

### 2. 保护用户数据
- ✅ 用户文档默认保留
- ✅ 图片、视频、音乐文件保留
- ✅ 项目文件和代码保留
- ✅ 配置文件保留

### 3. 确认再删除
- 🔍 危险操作前显示文件列表
- ❓ 请求用户确认
- 📋 提供撤销选项（回收站）
- 🕐 支持延迟删除

## 安全等级分类

### 等级1：安全（自动清理）
- 临时文件 (.tmp, .temp)
- 日志文件 (.log) - 30天前
- 浏览器缓存
- 缩略图缓存

### 等级2：低风险（建议清理）
- Windows更新缓存
- 预读文件
- 错误报告文件
- 系统还原点（旧版本）

### 等级3：中风险（需要确认）
- 下载文件夹（30天前）
- 应用程序缓存
- 重复文件
- 大文件（显示详情）

### 等级4：高风险（手动操作）
- 用户文档
- 项目文件
- 数据库文件
- 系统设置

## 保护机制

### 1. 模拟运行模式
```powershell
# 先模拟运行，查看将删除的文件
.\cleaner.ps1 -DryRun -Tasks temp,cache

# 确认无误后再实际运行
.\cleaner.ps1 -Tasks temp,cache
```

### 2. 文件备份
- 重要文件自动备份到临时目录
- 支持清理前导出文件列表
- 提供恢复脚本

### 3. 操作日志
- 记录所有删除操作
- 包含文件路径、大小、时间
- 支持操作回滚

### 4. 大小限制
- 单次清理不超过10GB
- 保留至少20%磁盘空间
- 大文件单独确认

## 危险操作防护

### 1. 系统目录保护
```powershell
# 受保护的系统目录
$protectedDirs = @(
    "C:\Windows",
    "C:\Program Files",
    "C:\Program Files (x86)",
    "C:\System Volume Information",
    "$env:USERPROFILE\AppData\Local\Microsoft\Windows"
)

# 检查是否在保护目录
function Test-ProtectedPath {
    param([string]$Path)
    foreach ($protected in $protectedDirs) {
        if ($Path -like "$protected*") {
            return $true
        }
    }
    return $false
}
```

### 2. 文件类型保护
```powershell
# 受保护的文件类型
$protectedExtensions = @(
    ".exe", ".dll", ".sys", ".drv",  # 可执行文件
    ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx",  # Office文档
    ".pdf", ".txt", ".rtf",  # 文档
    ".jpg", ".jpeg", ".png", ".gif", ".bmp",  # 图片
    ".mp3", ".mp4", ".avi", ".mkv",  # 媒体文件
    ".zip", ".rar", ".7z",  # 压缩文件
    ".sql", ".mdb", ".accdb"  # 数据库
)
```

### 3. 用户确认流程
```
[确认删除] 将删除以下文件：
1. C:\Users\Username\Downloads\old_file.zip (1.2 GB)
2. C:\Users\Username\AppData\Local\Temp\temp123.tmp (0.5 MB)
3. ... 还有 15 个文件

总计: 1.3 GB
是否继续？ [Y/N]: 
```

## 错误处理

### 1. 权限错误
- 跳过需要管理员权限的文件
- 记录无法访问的目录
- 提供权限提升建议

### 2. 文件占用错误
- 跳过正在使用的文件
- 建议关闭相关程序后重试
- 提供文件占用者信息

### 3. 磁盘空间不足
- 检查目标磁盘空间
- 分批次清理
- 建议先清理大文件

## 恢复机制

### 1. 回收站恢复
- 默认使用回收站删除
- 支持清空回收站确认
- 提供回收站管理建议

### 2. 备份恢复
```powershell
# 备份重要文件
$backupDir = "$env:TEMP\DiskCleanerBackup_$(Get-Date -Format 'yyyyMMdd')"
New-Item -ItemType Directory -Path $backupDir -Force

# 恢复备份
if (Test-Path $backupDir) {
    Copy-Item "$backupDir\*" -Destination $originalPath -Recurse
}
```

### 3. 操作日志恢复
```powershell
# 从日志恢复
$logFile = "C:\Logs\DiskCleaner_20240417.log"
$deletedFiles = Get-Content $logFile | ConvertFrom-Json

foreach ($file in $deletedFiles) {
    if (Test-Path $file.BackupPath) {
        Copy-Item $file.BackupPath -Destination $file.OriginalPath
    }
}
```

## 最佳安全实践

### 清理前
1. 备份重要数据
2. 关闭所有应用程序
3. 检查磁盘健康状态
4. 运行模拟清理

### 清理中
1. 分步骤进行
2. 每次清理后检查系统
3. 监控磁盘空间变化
4. 记录操作日志

### 清理后
1. 验证系统正常运行
2. 检查重要文件完整性
3. 清理备份文件（确认后）
4. 更新清理报告

## 紧急停止

### 停止脚本
```powershell
# 按 Ctrl+C 停止脚本
# 或使用停止函数
function Stop-Cleaning {
    Write-Host "正在停止清理操作..." -ForegroundColor Yellow
    # 清理临时文件
    # 恢复已删除文件（如果可能）
    exit 1
}
```

### 紧急恢复
1. 立即停止脚本 (Ctrl+C)
2. 检查回收站
3. 从备份恢复
4. 联系技术支持

## 免责声明

### 用户责任
- 用户需自行备份重要数据
- 用户需确认清理操作
- 用户需承担数据丢失风险

### 工具限制
- 不保证100%数据安全
- 不处理加密文件
- 不恢复已清空回收站的文件

### 技术支持
- 提供操作指导
- 协助故障排除
- 不承担数据恢复责任

---

*安全第一，谨慎操作*
*版本: v1.0 | 最后更新: 2026-04-17*