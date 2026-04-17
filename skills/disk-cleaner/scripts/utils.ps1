# 工具函数脚本
# 包含各种辅助函数和工具

function Get-DiskHealth {
    param([string]$DriveLetter = "C")
    
    try {
        $drive = Get-PSDrive $DriveLetter -ErrorAction Stop
        $totalSize = $drive.Used + $drive.Free
        $usedPercent = [math]::Round(($drive.Used / $totalSize) * 100, 1)
        
        $health = @{
            Drive = $DriveLetter
            TotalSize = $totalSize
            UsedSize = $drive.Used
            FreeSize = $drive.Free
            UsedPercent = $usedPercent
            Status = if ($usedPercent -lt 70) { "良好" } elseif ($usedPercent -lt 85) { "注意" } else { "警告" }
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        
        return $health
    } catch {
        return @{
            Drive = $DriveLetter
            Error = "无法访问磁盘"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
}

function Find-DuplicateFiles {
    param(
        [string]$Path = "C:\",
        [int]$MinSizeKB = 100,  # 最小文件大小（KB）
        [int]$MaxResults = 10
    )
    
    Write-Host "正在查找重复文件..." -ForegroundColor Cyan
    
    # 获取所有文件（排除系统目录）
    $allFiles = Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue | 
                Where-Object {$_.Length -gt ($MinSizeKB * 1KB) -and $_.DirectoryName -notlike "*Windows*" -and $_.DirectoryName -notlike "*Program Files*"}
    
    # 按文件名和大小分组
    $duplicates = $allFiles | Group-Object Name, Length | Where-Object {$_.Count -gt 1} | Sort-Object Count -Descending
    
    $results = @()
    $count = 0
    
    foreach ($group in $duplicates) {
        if ($count -ge $MaxResults) { break }
        
        $groupSize = ($group.Group | Measure-Object Length -Sum).Sum
        $avgSize = $groupSize / $group.Count
        
        $results += [PSCustomObject]@{
            Name = ($group.Name -split ', ')[0]
            Size = Format-Size $avgSize
            Copies = $group.Count
            TotalSize = Format-Size $groupSize
            Locations = ($group.Group | Select-Object -First 3 DirectoryName).DirectoryName
        }
        
        $count++
    }
    
    return $results
}

function Find-LargeDirectories {
    param(
        [string]$Path = "C:\",
        [int]$MinSizeMB = 100,
        [int]$MaxResults = 10
    )
    
    Write-Host "正在查找大目录..." -ForegroundColor Cyan
    
    $directories = Get-ChildItem $Path -Directory -ErrorAction SilentlyContinue | 
                   Where-Object {$_.Name -notin @("Windows", "Program Files", "Program Files (x86)", "System Volume Information")}
    
    $dirSizes = @()
    
    foreach ($dir in $directories) {
        $size = (Get-ChildItem $dir.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        
        if ($size -gt ($MinSizeMB * 1MB)) {
            $dirSizes += [PSCustomObject]@{
                Name = $dir.Name
                Path = $dir.FullName
                Size = Format-Size $size
                SizeBytes = $size
                FileCount = (Get-ChildItem $dir.FullName -Recurse -File -ErrorAction SilentlyContinue).Count
                LastModified = $dir.LastWriteTime
            }
        }
    }
    
    return $dirSizes | Sort-Object SizeBytes -Descending | Select-Object -First $MaxResults
}

function Get-SystemTempSize {
    $tempPaths = @(
        "$env:TEMP",
        "$env:WINDIR\Temp",
        "C:\Windows\Temp",
        "$env:LOCALAPPDATA\Temp"
    )
    
    $totalSize = 0
    $totalFiles = 0
    
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            $files = Get-ChildItem $path -File -Recurse -ErrorAction SilentlyContinue
            $totalFiles += $files.Count
            $totalSize += ($files | Measure-Object Length -Sum).Sum
        }
    }
    
    return @{
        Files = $totalFiles
        Size = $totalSize
        SizeFormatted = Format-Size $totalSize
    }
}

function Get-BrowserCacheSize {
    $cachePaths = @(
        @{Path="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"; Name="Edge"},
        @{Path="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"; Name="Chrome"},
        @{Path="$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"; Name="Firefox"}
    )
    
    $results = @()
    
    foreach ($cache in $cachePaths) {
        if (Test-Path $cache.Path) {
            $size = (Get-ChildItem $cache.Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            
            if ($size -gt 0) {
                $results += [PSCustomObject]@{
                    Browser = $cache.Name
                    Size = Format-Size $size
                    SizeBytes = $size
                    Path = $cache.Path
                }
            }
        }
    }
    
    return $results
}

function Format-Size {
    param([long]$Bytes)
    if ($Bytes -ge 1GB) {
        return "$([math]::Round($Bytes/1GB,2)) GB"
    } elseif ($Bytes -ge 1MB) {
        return "$([math]::Round($Bytes/1MB,2)) MB"
    } elseif ($Bytes -ge 1KB) {
        return "$([math]::Round($Bytes/1KB,2)) KB"
    } else {
        return "$Bytes B"
    }
}

function Write-Report {
    param([hashtable]$Data, [string]$Title)
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    foreach ($key in $Data.Keys) {
        $value = $Data[$key]
        Write-Host "$key : $value" -ForegroundColor Gray
    }
}

function Save-AnalysisReport {
    param(
        [hashtable]$Data,
        [string]$FilePath = "$env:USERPROFILE\Desktop\DiskAnalysis_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    )
    
    try {
        $Data | ConvertTo-Json -Depth 5 | Out-File -FilePath $FilePath -Encoding UTF8
        Write-Host "分析报告已保存到: $FilePath" -ForegroundColor Green
        return $FilePath
    } catch {
        Write-Host "保存报告失败: $_" -ForegroundColor Red
        return $null
    }
}

function Check-DiskErrors {
    param([string]$DriveLetter = "C")
    
    Write-Host "检查磁盘错误..." -ForegroundColor Cyan
    
    try {
        # 尝试运行chkdsk（只读模式）
        $output = chkdsk ${DriveLetter}: /scan 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            return @{
                Status = "正常"
                Message = "未发现磁盘错误"
                NeedsRepair = $false
            }
        } else {
            return @{
                Status = "需要修复"
                Message = "发现磁盘错误，建议运行 chkdsk ${DriveLetter}: /f"
                NeedsRepair = $true
            }
        }
    } catch {
        return @{
            Status = "检查失败"
            Message = "需要管理员权限运行磁盘检查"
            NeedsRepair = $null
        }
    }
}

function Get-DiskDefragStatus {
    param([string]$DriveLetter = "C")
    
    Write-Host "检查磁盘碎片状态..." -ForegroundColor Cyan
    
    try {
        $output = defrag ${DriveLetter}: /a 2>&1
        
        if ($output -match "不需要对该卷进行碎片整理") {
            return @{
                Status = "良好"
                Message = "无需碎片整理"
                NeedsDefrag = $false
            }
        } else {
            return @{
                Status = "建议整理"
                Message = "建议进行磁盘碎片整理"
                NeedsDefrag = $true
            }
        }
    } catch {
        return @{
            Status = "检查失败"
            Message = "无法检查碎片状态"
            NeedsDefrag = $null
        }
    }
}

# 导出函数
Export-ModuleMember -Function Get-DiskHealth, Find-DuplicateFiles, Find-LargeDirectories, Get-SystemTempSize, Get-BrowserCacheSize, Format-Size, Write-Report, Save-AnalysisReport, Check-DiskErrors, Get-DiskDefragStatus