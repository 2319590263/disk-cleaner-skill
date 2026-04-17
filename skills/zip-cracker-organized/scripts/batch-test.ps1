# 批量密码测试脚本
# 避免编码和执行问题

param(
    [string]$ArchivePath,
    [string[]]$Passwords,
    [string]$7zPath = "C:\Program Files\7-Zip\7z.exe"
)

function Test-Password {
    param(
        [string]$ArchivePath,
        [string]$Password,
        [string]$7zPath
    )
    
    # 直接使用命令行，避免PowerShell管道问题
    $process = Start-Process -FilePath $7zPath `
        -ArgumentList "t", "-p$Password", "`"$ArchivePath`"" `
        -NoNewWindow -Wait -PassThru -RedirectStandardOutput "nul" -RedirectStandardError "nul"
    
    return $process.ExitCode -eq 0
}

# 主逻辑
if (-not (Test-Path $ArchivePath)) {
    Write-Host "错误: 文件不存在 - $ArchivePath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $7zPath)) {
    Write-Host "错误: 7-Zip未安装 - $7zPath" -ForegroundColor Red
    exit 1
}

Write-Host "批量测试密码..." -ForegroundColor Cyan
Write-Host "文件: $(Split-Path $ArchivePath -Leaf)" -ForegroundColor Cyan
Write-Host "密码数量: $($Passwords.Count)" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

$found = $false
$tested = 0

foreach ($password in $Passwords) {
    $tested++
    Write-Host "测试 [$tested/$($Passwords.Count)]: $password" -NoNewline
    
    if (Test-Password -ArchivePath $ArchivePath -Password $password -7zPath $7zPath) {
        Write-Host "`r✅ 找到密码: $password" -ForegroundColor Green
        $found = $true
        break
    } else {
        Write-Host "`r" -NoNewline
    }
    
    # 每10个显示一次进度
    if ($tested % 10 -eq 0) {
        Write-Host "进度: $tested/$($Passwords.Count)" -ForegroundColor DarkYellow
    }
}

if (-not $found) {
    Write-Host "`n❌ 未找到正确密码" -ForegroundColor Red
}

Write-Host "`n测试完成" -ForegroundColor Cyan