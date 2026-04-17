# 使用示例

## 基本用法

### 1. 快速分析磁盘状态
```powershell
# 分析C盘状态
.\scripts\analyze.ps1 -Drive C

# 分析D盘状态（深度扫描）
.\scripts\analyze.ps1 -Drive D -DeepScan
```

### 2. 执行清理操作
```powershell
# 清理临时文件和缓存
.\scripts\cleaner.ps1 -Tasks temp,cache

# 清理下载文件夹和回收站（需要确认）
.\scripts\cleaner.ps1 -Tasks downloads,recycle -Confirm

# 模拟运行，查看将清理的文件
.\scripts\cleaner.ps1 -Tasks temp,cache,updates -DryRun
```

### 3. 使用工具函数
```powershell
# 导入工具模块
. .\scripts\utils.ps1

# 检查磁盘健康状态
Get-DiskHealth -DriveLetter C

# 查找重复文件
Find-DuplicateFiles -Path "D:\" -MinSizeKB 1024

# 查找大目录
Find-LargeDirectories -Path "C:\" -MinSizeMB 500
```

## OpenClaw集成示例

### 通过OpenClaw调用
```bash
# 运行完整清理流程
openclaw agent --skill disk-cleaner --message "清理电脑垃圾文件"

# 只检查不清理
openclaw agent --skill disk-cleaner --message "检查磁盘状态"

# 清理特定项目
openclaw agent --skill disk-cleaner --message "清理临时文件"
```

### 技能响应示例
```
用户: 清理电脑垃圾文件

助手: 开始磁盘清理流程...
1. 分析磁盘状态...
   C盘: 已使用 85.3 GB (78%), 剩余 23.7 GB
   D盘: 已使用 45.2 GB (32%), 剩余 95.8 GB

2. 发现可清理项目:
   ✅ 临时文件: 2.3 GB
   ✅ 浏览器缓存: 1.1 GB
   ⚠️ 下载文件夹(30天前): 5.2 GB (需要确认)
   ⚠️ 回收站: 3.8 GB (需要确认)

是否开始清理？ [是/否/部分]:
```

## 实际场景示例

### 场景1: 磁盘空间不足紧急清理
```powershell
# 紧急清理脚本
$emergencyTasks = @("temp", "cache", "recycle", "updates")
.\scripts\cleaner.ps1 -Tasks $emergencyTasks -Confirm:$false

# 检查清理效果
$health = Get-DiskHealth -DriveLetter C
if ($health.UsedPercent -lt 80) {
    Write-Host "✅ 紧急清理成功，C盘使用率: $($health.UsedPercent)%" -ForegroundColor Green
} else {
    Write-Host "⚠️ 需要进一步清理，建议检查大文件" -ForegroundColor Yellow
}
```

### 场景2: 定期系统维护
```powershell
# 每周维护脚本
function Invoke-WeeklyMaintenance {
    # 1. 分析磁盘状态
    Write-Host "=== 每周磁盘维护 ===" -ForegroundColor Cyan
    $analysis = .\scripts\analyze.ps1 -Drive C
    
    # 2. 安全清理
    $safeTasks = @("temp", "cache", "logs")
    $result = .\scripts\cleaner.ps1 -Tasks $safeTasks
    
    # 3. 生成报告
    $report = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Analysis = $analysis | ConvertFrom-Json
        CleanResult = $result | ConvertFrom-Json
    }
    
    $report | ConvertTo-Json -Depth 3 | Out-File "weekly_maintenance_$(Get-Date -Format 'yyyyMMdd').json"
    
    Write-Host "✅ 每周维护完成" -ForegroundColor Green
}

Invoke-WeeklyMaintenance
```

### 场景3: 项目目录清理
```powershell
# 清理开发项目目录
function Clean-ProjectDirectory {
    param([string]$ProjectPath)
    
    Write-Host "清理项目目录: $ProjectPath" -ForegroundColor Cyan
    
    # 1. 查找node_modules目录
    $nodeModules = Get-ChildItem $ProjectPath -Recurse -Directory -Filter "node_modules" -ErrorAction SilentlyContinue
    
    if ($nodeModules) {
        $totalSize = 0
        foreach ($dir in $nodeModules) {
            $size = (Get-ChildItem $dir.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            $sizeGB = [math]::Round($size/1GB, 2)
            $totalSize += $size
            
            Write-Host "  $($dir.FullName): $sizeGB GB" -ForegroundColor Gray
        }
        
        $totalSizeGB = [math]::Round($totalSize/1GB, 2)
        Write-Host "总计: $totalSizeGB GB" -ForegroundColor Yellow
        
        # 确认删除
        $confirm = Read-Host "是否删除这些node_modules目录？ (y/n)"
        if ($confirm -eq 'y') {
            foreach ($dir in $nodeModules) {
                Remove-Item $dir.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "✅ 已清理，释放 $totalSizeGB GB" -ForegroundColor Green
        }
    } else {
        Write-Host "未找到node_modules目录" -ForegroundColor Green
    }
}

# 使用示例
Clean-ProjectDirectory -ProjectPath "D:\Projects"
```

## 自动化脚本示例

### 计划任务脚本
```powershell
# scheduled_clean.ps1 - 计划任务脚本
param(
    [string]$Mode = "quick"  # quick, deep, custom
)

switch ($Mode) {
    "quick" {
        # 快速清理：临时文件和缓存
        $tasks = @("temp", "cache")
        $logFile = "C:\Logs\clean_quick_$(Get-Date -Format 'yyyyMMdd').log"
    }
    "deep" {
        # 深度清理：包括下载文件夹和回收站
        $tasks = @("temp", "cache", "downloads", "recycle", "updates")
        $logFile = "C:\Logs\clean_deep_$(Get-Date -Format 'yyyyMMdd').log"
    }
    default {
        $tasks = @("temp", "cache")
        $logFile = "C:\Logs\clean_$(Get-Date -Format 'yyyyMMdd').log"
    }
}

# 开始清理
Write-Host "开始 $Mode 清理模式..." | Tee-Object -FilePath $logFile
$result = .\scripts\cleaner.ps1 -Tasks $tasks -Confirm:$false

# 记录结果
$result | ConvertTo-Json -Depth 3 | Out-File $logFile -Append
Write-Host "清理完成，日志: $logFile" | Tee-Object -FilePath $logFile -Append
```

### Windows计划任务配置
```powershell
# 创建计划任务
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"C:\Scripts\scheduled_clean.ps1`" -Mode quick"

$trigger = New-ScheduledTaskTrigger -Daily -At 2am
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "WeeklyDiskCleanup" `
    -Action $action -Trigger $trigger -Principal $principal `
    -Description "每周磁盘清理任务"
```

## 故障排除示例

### 问题1: 权限不足
```powershell
# 检查当前权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "⚠️ 需要管理员权限运行某些清理任务" -ForegroundColor Yellow
    Write-Host "请以管理员身份运行PowerShell" -ForegroundColor Gray
    
    # 跳过需要管理员权限的任务
    $tasks = @("temp", "cache", "downloads")  # 这些不需要管理员权限
} else {
    $tasks = @("temp", "cache", "downloads", "recycle", "updates")
}
```

### 问题2: 文件被占用
```powershell
# 检查文件占用
function Test-FileInUse {
    param([string]$FilePath)
    
    try {
        [IO.File]::OpenWrite($FilePath).Close()
        return $false
    } catch {
        return $true
    }
}

# 安全删除函数
function Safe-RemoveItem {
    param([string]$Path)
    
    if (Test-FileInUse -FilePath $Path) {
        Write-Host "文件被占用: $Path" -ForegroundColor Yellow
        return $false
    } else {
        Remove-Item $Path -Force -ErrorAction SilentlyContinue
        return $true
    }
}
```

### 问题3: 磁盘空间不足
```powershell
# 检查磁盘空间
function Test-DiskSpace {
    param([string]$DriveLetter, [long]$RequiredBytes)
    
    $drive = Get-PSDrive $DriveLetter -ErrorAction SilentlyContinue
    if ($drive) {
        $freeSpace = $drive.Free
        return $freeSpace -gt $RequiredBytes
    }
    return $false
}

# 分批次清理
function Clean-InBatches {
    param([string[]]$Files, [int]$BatchSizeMB = 100)
    
    $batch = @()
    $batchSize = 0
    
    foreach ($file in $Files) {
        $batch += $file
        $batchSize += $file.Length
        
        if ($batchSize -gt ($BatchSizeMB * 1MB)) {
            # 清理这一批
            $batch | Remove-Item -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1  # 给系统一些时间
            
            $batch = @()
            $batchSize = 0
        }
    }
    
    # 清理剩余文件
    if ($batch.Count -gt 0) {
        $batch | Remove-Item -Force -ErrorAction SilentlyContinue
    }
}
```

## 高级用法

### 自定义清理规则
```powershell
# custom_clean.ps1 - 自定义清理规则
$customRules = @{
    "OldProjects" = {
        param([string]$Path)
        # 清理6个月前的项目备份
        $cutoffDate = (Get-Date).AddMonths(-6)
        Get-ChildItem $Path -Filter "*.bak" -Recurse | 
            Where-Object {$_.LastWriteTime -lt $cutoffDate} |
            Remove-Item -Force
    }
    
    "LargeLogs" = {
        param([string]$Path)
        # 清理大于100MB的日志文件
        Get-ChildItem $Path -Filter "*.log" -Recurse | 
            Where-Object {$_.Length -gt 100MB} |
            Remove-Item -Force
    }
}

# 应用自定义规则
foreach ($rule in $customRules.Keys) {
    Write-Host "应用规则: $rule" -ForegroundColor Cyan
    & $customRules[$rule] -Path "D:\"
}
```

### 集成到其他工具
```powershell
# 集成到系统监控工具
function Monitor-DiskHealth {
    $threshold = 80  # 警告阈值
    $checkInterval = 3600  # 检查间隔（秒）
    
    while ($true) {
        $health = Get-DiskHealth -DriveLetter C
        
        if ($health.UsedPercent -gt $threshold) {
            # 触发自动清理
            Write-Host "⚠️ C盘使用率过高: $($health.UsedPercent)%" -ForegroundColor Red
            .\scripts\cleaner.ps1 -Tasks temp,cache -Confirm:$false
        }
        
        Start-Sleep -Seconds $checkInterval
    }
}
```

---

## 总结

### 推荐的工作流程
1. **分析阶段**: 使用 `analyze.ps1` 了解磁盘状态
2. **计划阶段**: 根据分析结果选择清理任务
3. **执行阶段**: 使用 `cleaner.ps1` 执行清理
4. **验证阶段**: 检查清理效果和系统状态

### 最佳实践
- 始终先运行模拟模式 (`-DryRun`)
- 定期备份重要数据
- 监控磁盘使用趋势
- 根据实际需求调整配置

### 获取帮助
```powershell
# 查看脚本帮助
Get-Help .\scripts\analyze.ps1 -Detailed
Get-Help .\scripts\cleaner.ps1 -Detailed

# 查看配置说明
Get-Content .\config.json | ConvertFrom-Json | Format-List
```

---

*示例文档版本: v1.0*
*最后更新: 2026-04-17*