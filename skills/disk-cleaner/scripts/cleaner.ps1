# 磁盘清理脚本
# 功能：执行安全的磁盘清理操作

param(
    [string[]]$Tasks = @("temp", "cache", "downloads", "recycle"),
    [switch]$DryRun = $false,
    [switch]$Confirm = $true
)

function Write-ColorOutput {
    param([string]$Text, [string]$Color = "White")
    $colors = @{
        "Green" = "32"; "Red" = "31"; "Yellow" = "33"
        "Blue" = "34"; "Magenta" = "35"; "Cyan" = "36"
        "Gray" = "90"
    }
    if ($colors.ContainsKey($Color)) {
        Write-Host "`e[${($colors[$Color])}m$Text`e[0m"
    } else {
        Write-Host $Text
    }
}

function Format-Size {
    param([long]$Bytes)
    if ($Bytes -ge 1GB) {
        return "$([math]::Round($Bytes/1GB,2)) GB"
    } elseif ($Bytes -ge 1MB) {
        return "$([math]::Round($Bytes/1MB,2)) MB"
    } else {
        return "$([math]::Round($Bytes/1KB,2)) KB"
    }
}

# 清理任务定义
$taskDefinitions = @{
    "temp" = @{
        Name = "临时文件清理"
        Description = "清理系统临时文件、日志文件等"
        Safe = $true
        Function = {
            param([switch]$DryRun)
            
            $paths = @(
                "$env:TEMP",
                "$env:WINDIR\Temp",
                "C:\Windows\Temp",
                "$env:LOCALAPPDATA\Temp"
            )
            
            $totalDeleted = 0
            $totalSize = 0
            
            foreach ($path in $paths) {
                if (Test-Path $path) {
                    $files = Get-ChildItem $path -File -Recurse -ErrorAction SilentlyContinue
                    $fileCount = $files.Count
                    $size = ($files | Measure-Object Length -Sum).Sum
                    
                    if ($fileCount -gt 0) {
                        Write-ColorOutput "  $path : $fileCount 个文件 ($(Format-Size $size))" -Color "Gray"
                        
                        if (-not $DryRun) {
                            $files | Remove-Item -Force -ErrorAction SilentlyContinue
                            Write-ColorOutput "    ✅ 已清理" -Color "Green"
                        } else {
                            Write-ColorOutput "    🔍 模拟清理" -Color "Yellow"
                        }
                        
                        $totalDeleted += $fileCount
                        $totalSize += $size
                    }
                }
            }
            
            return @{
                Deleted = $totalDeleted
                Size = $totalSize
            }
        }
    }
    
    "cache" = @{
        Name = "浏览器缓存清理"
        Description = "清理Edge、Chrome等浏览器缓存"
        Safe = $true
        Function = {
            param([switch]$DryRun)
            
            $cachePaths = @(
                "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
                "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
                "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
                "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache"
            )
            
            $totalDeleted = 0
            $totalSize = 0
            
            foreach ($cache in $cachePaths) {
                if (Test-Path $cache) {
                    $files = Get-ChildItem $cache -File -Recurse -ErrorAction SilentlyContinue
                    $fileCount = $files.Count
                    $size = ($files | Measure-Object Length -Sum).Sum
                    
                    if ($fileCount -gt 0) {
                        $cacheName = Split-Path (Split-Path $cache -Parent) -Leaf
                        Write-ColorOutput "  $cacheName 缓存 : $fileCount 个文件 ($(Format-Size $size))" -Color "Gray"
                        
                        if (-not $DryRun) {
                            $files | Remove-Item -Force -ErrorAction SilentlyContinue
                            Write-ColorOutput "    ✅ 已清理" -Color "Green"
                        } else {
                            Write-ColorOutput "    🔍 模拟清理" -Color "Yellow"
                        }
                        
                        $totalDeleted += $fileCount
                        $totalSize += $size
                    }
                }
            }
            
            return @{
                Deleted = $totalDeleted
                Size = $totalSize
            }
        }
    }
    
    "downloads" = @{
        Name = "下载文件夹清理"
        Description = "清理下载文件夹中的旧文件"
        Safe = $false  # 需要确认
        Function = {
            param([switch]$DryRun)
            
            $downloadsPath = "$env:USERPROFILE\Downloads"
            $cutoffDate = (Get-Date).AddDays(-30)  # 30天前的文件
            
            if (Test-Path $downloadsPath) {
                $oldFiles = Get-ChildItem $downloadsPath -File -ErrorAction SilentlyContinue | 
                           Where-Object {$_.LastWriteTime -lt $cutoffDate}
                
                $fileCount = $oldFiles.Count
                $size = ($oldFiles | Measure-Object Length -Sum).Sum
                
                if ($fileCount -gt 0) {
                    Write-ColorOutput "  下载文件夹 : $fileCount 个30天前的文件 ($(Format-Size $size))" -Color "Gray"
                    
                    # 显示前5个文件
                    Write-ColorOutput "  示例文件:" -Color "Gray"
                    $oldFiles | Select-Object -First 5 Name, @{Name="Size";Expression={Format-Size $_.Length}}, LastWriteTime | Format-Table -AutoSize
                    
                    if (-not $DryRun) {
                        $oldFiles | Remove-Item -Force -ErrorAction SilentlyContinue
                        Write-ColorOutput "    ✅ 已清理" -Color "Green"
                    } else {
                        Write-ColorOutput "    🔍 模拟清理" -Color "Yellow"
                    }
                    
                    return @{
                        Deleted = $fileCount
                        Size = $size
                    }
                } else {
                    Write-ColorOutput "  没有30天前的文件" -Color "Green"
                    return @{ Deleted = 0; Size = 0 }
                }
            }
            
            return @{ Deleted = 0; Size = 0 }
        }
    }
    
    "recycle" = @{
        Name = "回收站清理"
        Description = "清空回收站"
        Safe = $false  # 需要确认
        Function = {
            param([switch]$DryRun)
            
            $shell = New-Object -ComObject Shell.Application
            $recycleBin = $shell.Namespace(0xA)
            $items = $recycleBin.Items()
            $itemCount = $items.Count
            
            if ($itemCount -gt 0) {
                $totalSize = 0
                for ($i = 0; $i -lt $itemCount; $i++) {
                    $totalSize += $items.Item($i).Size
                }
                
                Write-ColorOutput "  回收站 : $itemCount 个项目 ($(Format-Size $totalSize))" -Color "Gray"
                
                if (-not $DryRun) {
                    try {
                        Clear-RecycleBin -Force -ErrorAction Stop
                        Write-ColorOutput "    ✅ 已清空" -Color "Green"
                    } catch {
                        # 尝试其他方法
                        $recyclePaths = @("$env:SystemDrive`:\`$Recycle.Bin", "C:\`$Recycle.Bin")
                        foreach ($path in $recyclePaths) {
                            if (Test-Path $path) {
                                Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                            }
                        }
                        Write-ColorOutput "    ✅ 已清空" -Color "Green"
                    }
                } else {
                    Write-ColorOutput "    🔍 模拟清理" -Color "Yellow"
                }
                
                return @{
                    Deleted = $itemCount
                    Size = $totalSize
                }
            } else {
                Write-ColorOutput "  回收站已经是空的" -Color "Green"
                return @{ Deleted = 0; Size = 0 }
            }
        }
    }
    
    "updates" = @{
        Name = "Windows更新缓存"
        Description = "清理Windows更新缓存文件"
        Safe = $true
        Function = {
            param([switch]$DryRun)
            
            $updatePath = "C:\Windows\SoftwareDistribution\Download"
            
            if (Test-Path $updatePath) {
                $files = Get-ChildItem $updatePath -File -Recurse -ErrorAction SilentlyContinue
                $fileCount = $files.Count
                $size = ($files | Measure-Object Length -Sum).Sum
                
                if ($fileCount -gt 0) {
                    Write-ColorOutput "  Windows更新缓存 : $fileCount 个文件 ($(Format-Size $size))" -Color "Gray"
                    
                    if (-not $DryRun) {
                        # 先停止Windows Update服务
                        $wuService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
                        if ($wuService.Status -eq 'Running') {
                            Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
                            Start-Sleep -Seconds 2
                        }
                        
                        $files | Remove-Item -Force -ErrorAction SilentlyContinue
                        
                        # 重新启动服务
                        if ($wuService) {
                            Start-Service -Name wuauserv -ErrorAction SilentlyContinue
                        }
                        
                        Write-ColorOutput "    ✅ 已清理" -Color "Green"
                    } else {
                        Write-ColorOutput "    🔍 模拟清理" -Color "Yellow"
                    }
                    
                    return @{
                        Deleted = $fileCount
                        Size = $size
                    }
                }
            }
            
            return @{ Deleted = 0; Size = 0 }
        }
    }
}

# 主清理函数
function Invoke-CleanTasks {
    param([string[]]$TaskNames, [switch]$DryRun, [switch]$Confirm)
    
    Write-ColorOutput "`n开始磁盘清理操作" -Color "Cyan"
    Write-ColorOutput ("=" * 60) -Color "Cyan"
    
    if ($DryRun) {
        Write-ColorOutput "模拟运行模式 - 不会实际删除文件" -Color "Yellow"
    }
    
    $results = @()
    $totalDeleted = 0
    $totalSize = 0
    
    foreach ($taskName in $TaskNames) {
        if ($taskDefinitions.ContainsKey($taskName)) {
            $task = $taskDefinitions[$taskName]
            
            Write-ColorOutput "`n[$taskName] $($task.Name)" -Color "Cyan"
            Write-ColorOutput "$($task.Description)" -Color "Gray"
            
            # 安全检查
            if (-not $task.Safe -and $Confirm) {
                Write-ColorOutput "⚠️ 此操作可能需要确认，请谨慎操作" -Color "Yellow"
            }
            
            # 执行清理任务
            try {
                $result = & $task.Function -DryRun:$DryRun
                
                if ($result) {
                    $results += [PSCustomObject]@{
                        Task = $task.Name
                        Deleted = $result.Deleted
                        Size = $result.Size
                        SizeFormatted = Format-Size $result.Size
                    }
                    
                    $totalDeleted += $result.Deleted
                    $totalSize += $result.Size
                }
                
            } catch {
                Write-ColorOutput "  ❌ 清理失败: $_" -Color "Red"
            }
        } else {
            Write-ColorOutput "  ⚠️ 未知任务: $taskName" -Color "Yellow"
        }
    }
    
    # 显示清理结果
    Write-ColorOutput "`n清理结果汇总" -Color "Cyan"
    Write-ColorOutput ("-" * 40) -Color "Gray"
    
    if ($results.Count -gt 0) {
        foreach ($result in $results) {
            if ($result.Deleted -gt 0) {
                Write-ColorOutput "  $($result.Task): $($result.Deleted) 个文件 ($($result.SizeFormatted))" -Color "Green"
            } else {
                Write-ColorOutput "  $($result.Task): 无文件可清理" -Color "Gray"
            }
        }
        
        Write-ColorOutput "`n总计: $totalDeleted 个文件 ($(Format-Size $totalSize))" -Color "Green"
    } else {
        Write-ColorOutput "  没有执行任何清理操作" -Color "Gray"
    }
    
    if ($DryRun) {
        Write-ColorOutput "`n⚠️ 模拟运行完成，实际可释放 $(Format-Size $totalSize)" -Color "Yellow"
    } else {
        Write-ColorOutput "`n✅ 清理操作完成" -Color "Green"
    }
    
    Write-ColorOutput ("=" * 60) -Color "Cyan"
    
    return @{
        TotalDeleted = $totalDeleted
        TotalSize = $totalSize
        Results = $results
    }
}

# 执行清理
$cleanResult = Invoke-CleanTasks -TaskNames $Tasks -DryRun:$DryRun -Confirm:$Confirm

# 输出JSON格式结果
$cleanResult | ConvertTo-Json -Depth 3