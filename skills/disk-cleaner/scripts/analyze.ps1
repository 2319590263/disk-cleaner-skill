# 磁盘分析脚本
# 功能：分析磁盘状态，识别可清理项目

param(
    [string]$Drive = "C",
    [switch]$DeepScan = $false
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

function Get-DirectorySize {
    param([string]$Path)
    try {
        $size = (Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        return $size
    } catch {
        return 0
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

# 主分析函数
function Analyze-Disk {
    param([string]$DriveLetter)
    
    Write-ColorOutput "`n开始分析 ${DriveLetter}: 盘..." -Color "Cyan"
    Write-ColorOutput ("=" * 60) -Color "Cyan"
    
    # 检查磁盘是否存在
    try {
        $drive = Get-PSDrive $DriveLetter -ErrorAction Stop
    } catch {
        Write-ColorOutput "错误: ${DriveLetter}: 盘不存在或无法访问" -Color "Red"
        return $null
    }
    
    # 磁盘基本信息
    $totalSize = $drive.Used + $drive.Free
    $usedPercent = [math]::Round(($drive.Used / $totalSize) * 100, 1)
    
    Write-ColorOutput "磁盘容量: $(Format-Size $totalSize)" -Color "Gray"
    Write-ColorOutput "已使用: $(Format-Size $drive.Used) ($usedPercent%)" -Color $(if ($usedPercent -gt 80) { "Red" } elseif ($usedPercent -gt 60) { "Yellow" } else { "Green" })
    Write-ColorOutput "剩余: $(Format-Size $drive.Free)" -Color "Green"
    
    # 健康状态评估
    Write-ColorOutput "`n健康状态评估:" -Color "Cyan"
    if ($usedPercent -lt 70) {
        Write-ColorOutput "  ✅ 良好 (使用率 $usedPercent%)" -Color "Green"
    } elseif ($usedPercent -lt 85) {
        Write-ColorOutput "  ⚠️ 注意 (使用率 $usedPercent%)" -Color "Yellow"
    } else {
        Write-ColorOutput "  ❌ 警告 (使用率 $usedPercent%)" -Color "Red"
    }
    
    # 分析主要目录
    Write-ColorOutput "`n主要目录分析:" -Color "Cyan"
    
    $mainDirs = @()
    if ($DriveLetter -eq "C") {
        $mainDirs = @(
            @{Path="$env:USERPROFILE\Desktop"; Name="桌面"},
            @{Path="$env:USERPROFILE\Documents"; Name="文档"},
            @{Path="$env:USERPROFILE\Downloads"; Name="下载"},
            @{Path="$env:USERPROFILE\Pictures"; Name="图片"},
            @{Path="$env:LOCALAPPDATA"; Name="本地应用数据"},
            @{Path="$env:APPDATA"; Name="漫游应用数据"},
            @{Path="C:\Windows"; Name="Windows系统"},
            @{Path="C:\Program Files"; Name="程序文件"},
            @{Path="C:\Program Files (x86)"; Name="程序文件(x86)"}
        )
    } else {
        # D盘分析顶级目录
        $rootDirs = Get-ChildItem "${DriveLetter}:\" -Directory -ErrorAction SilentlyContinue | Select-Object -First 10
        foreach ($dir in $rootDirs) {
            $mainDirs += @{Path=$dir.FullName; Name=$dir.Name}
        }
    }
    
    $dirSizes = @()
    foreach ($dir in $mainDirs) {
        if (Test-Path $dir.Path) {
            $size = Get-DirectorySize -Path $dir.Path
            if ($size -gt 0) {
                $dirSizes += [PSCustomObject]@{
                    Directory = $dir.Name
                    Size = Format-Size $size
                    SizeBytes = $size
                    Path = $dir.Path
                }
            }
        }
    }
    
    # 显示前5个最大的目录
    $topDirs = $dirSizes | Sort-Object SizeBytes -Descending | Select-Object -First 5
    foreach ($dir in $topDirs) {
        Write-ColorOutput "  $($dir.Directory): $($dir.Size)" -Color "Gray"
    }
    
    # 查找大文件
    Write-ColorOutput "`n大文件检查 (>100MB):" -Color "Cyan"
    $largeFiles = Get-ChildItem "${DriveLetter}:\" -Recurse -File -ErrorAction SilentlyContinue | 
                   Where-Object {$_.Length -gt 100MB} | 
                   Select-Object -First 5 FullName, @{Name="Size";Expression={Format-Size $_.Length}}, LastWriteTime
    
    if ($largeFiles) {
        foreach ($file in $largeFiles) {
            $fileName = Split-Path $file.FullName -Leaf
            Write-ColorOutput "  $($file.Size): $fileName" -Color "Gray"
        }
    } else {
        Write-ColorOutput "  未找到大于100MB的文件" -Color "Green"
    }
    
    # 查找临时文件
    Write-ColorOutput "`n临时文件检查:" -Color "Cyan"
    $tempPatterns = @("*.tmp", "*.temp", "*.bak", "*.old", "*.log")
    $tempFiles = Get-ChildItem "${DriveLetter}:\" -Recurse -Include $tempPatterns -ErrorAction SilentlyContinue | Select-Object -First 20
    
    if ($tempFiles) {
        $tempSize = ($tempFiles | Measure-Object Length -Sum).Sum
        Write-ColorOutput "  找到 $($tempFiles.Count) 个临时文件，约 $(Format-Size $tempSize)" -Color "Gray"
        
        # 按类型分组
        $byType = $tempFiles | Group-Object Extension
        foreach ($type in $byType) {
            $typeSize = ($type.Group | Measure-Object Length -Sum).Sum
            Write-ColorOutput "    $($type.Name): $($type.Count) 个 ($(Format-Size $typeSize))" -Color "Gray"
        }
    } else {
        Write-ColorOutput "  未找到临时文件" -Color "Green"
    }
    
    # 深度扫描（如果启用）
    if ($DeepScan) {
        Write-ColorOutput "`n深度扫描:" -Color "Cyan"
        
        # 检查重复文件
        Write-ColorOutput "  重复文件检查..." -Color "Gray"
        $allFiles = Get-ChildItem "${DriveLetter}:\" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1000
        $duplicateNames = $allFiles | Group-Object Name | Where-Object {$_.Count -gt 1} | Sort-Object Count -Descending | Select-Object -First 3
        
        if ($duplicateNames) {
            Write-ColorOutput "  发现重复文件:" -Color "Yellow"
            foreach ($dup in $duplicateNames) {
                Write-ColorOutput "    $($dup.Name): $($dup.Count) 个副本" -Color "Gray"
            }
        }
        
        # 检查node_modules目录
        Write-ColorOutput "  node_modules目录检查..." -Color "Gray"
        $nodeModules = Get-ChildItem "${DriveLetter}:\" -Recurse -Directory -Filter "node_modules" -ErrorAction SilentlyContinue
        if ($nodeModules) {
            Write-ColorOutput "  找到 $($nodeModules.Count) 个node_modules目录" -Color "Gray"
        }
    }
    
    # 生成分析报告
    $report = [PSCustomObject]@{
        Drive = $DriveLetter
        TotalSize = $totalSize
        UsedSize = $drive.Used
        FreeSize = $drive.Free
        UsedPercent = $usedPercent
        TopDirectories = $topDirs
        LargeFiles = $largeFiles
        TempFilesCount = if ($tempFiles) { $tempFiles.Count } else { 0 }
        TempFilesSize = if ($tempFiles) { $tempSize } else { 0 }
        HealthStatus = if ($usedPercent -lt 70) { "良好" } elseif ($usedPercent -lt 85) { "注意" } else { "警告" }
    }
    
    Write-ColorOutput "`n分析完成" -Color "Green"
    Write-ColorOutput ("=" * 60) -Color "Cyan"
    
    return $report
}

# 执行分析
$result = Analyze-Disk -DriveLetter $Drive

# 输出JSON格式结果（供其他脚本使用）
if ($result) {
    $result | ConvertTo-Json -Depth 3
}