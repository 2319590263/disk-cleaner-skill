# 可靠的密码测试脚本
# 避免PowerShell编码和执行问题

param(
    [string]$ArchivePath,
    [string]$Password,
    [string]$7zPath = "C:\Program Files\7-Zip\7z.exe"
)

function Test-ArchivePassword {
    param(
        [string]$ArchivePath,
        [string]$Password,
        [string]$7zPath
    )
    
    # 使用简单的命令行测试
    $tempFile = [System.IO.Path]::GetTempFileName()
    
    # 测试密码
    & $7zPath t "-p$Password" $ArchivePath 2>&1 > $tempFile
    
    $exitCode = $LASTEXITCODE
    $output = Get-Content $tempFile -Raw
    
    # 清理临时文件
    Remove-Item $tempFile -Force
    
    # 检查输出中是否包含成功信息
    if ($exitCode -eq 0 -or $output -match "Everything is Ok") {
        return $true
    }
    return $false
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

Write-Host "测试密码: $Password" -ForegroundColor Yellow
Write-Host "文件: $(Split-Path $ArchivePath -Leaf)" -ForegroundColor Cyan

if (Test-ArchivePassword -ArchivePath $ArchivePath -Password $Password -7zPath $7zPath) {
    Write-Host "✅ 密码正确: $Password" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ 密码错误: $Password" -ForegroundColor Red
    exit 1
}