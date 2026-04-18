# Git静默安装脚本
$installer = "D:\Git-Installer.exe"
$installDir = "D:\Git"

Write-Host "正在安装Git到 $installDir ..." -ForegroundColor Yellow

# 检查安装程序是否存在
if (-not (Test-Path $installer)) {
    Write-Host "错误: 安装程序不存在: $installer" -ForegroundColor Red
    exit 1
}

# 静默安装参数
$installArgs = @(
    "/VERYSILENT",
    "/NORESTART",
    "/NOCANCEL",
    "/SP-",
    "/CLOSEAPPLICATIONS",
    "/RESTARTAPPLICATIONS",
    "/COMPONENTS=`"icons,ext\reg\shellhere,assoc,assoc_sh`"",
    "/DIR=`"$installDir`"",
    "/NOICONS"
)

# 执行安装
Write-Host "开始安装Git..." -ForegroundColor Yellow
Start-Process -FilePath $installer -ArgumentList $installArgs -Wait

# 等待安装完成
Start-Sleep -Seconds 10

# 添加Git到系统PATH
Write-Host "配置系统PATH..." -ForegroundColor Yellow
$envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($envPath -notlike "*$installDir\cmd*") {
    $newPath = "$installDir\cmd;$installDir\bin;$envPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    $env:Path = "$installDir\cmd;$installDir\bin;$env:Path"
}

Write-Host "Git安装完成！" -ForegroundColor Green
Write-Host "安装目录: $installDir" -ForegroundColor Cyan

# 验证安装
Write-Host "验证Git安装..." -ForegroundColor Yellow
try {
    git --version
    Write-Host "Git安装成功！" -ForegroundColor Green
} catch {
    Write-Host "Git验证失败，可能需要重启终端" -ForegroundColor Yellow
}