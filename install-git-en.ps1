# Git silent installation script
$installer = "D:\Git-Installer.exe"
$installDir = "D:\Git"

Write-Host "Installing Git to $installDir ..." -ForegroundColor Yellow

# Check if installer exists
if (-not (Test-Path $installer)) {
    Write-Host "Error: Installer not found: $installer" -ForegroundColor Red
    exit 1
}

# Silent installation arguments
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

# Execute installation
Write-Host "Starting Git installation..." -ForegroundColor Yellow
Start-Process -FilePath $installer -ArgumentList $installArgs -Wait

# Wait for installation to complete
Start-Sleep -Seconds 10

# Add Git to system PATH
Write-Host "Configuring system PATH..." -ForegroundColor Yellow
$envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($envPath -notlike "*$installDir\cmd*") {
    $newPath = "$installDir\cmd;$installDir\bin;$envPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    $env:Path = "$installDir\cmd;$installDir\bin;$env:Path"
}

Write-Host "Git installation completed!" -ForegroundColor Green
Write-Host "Installation directory: $installDir" -ForegroundColor Cyan

# Verify installation
Write-Host "Verifying Git installation..." -ForegroundColor Yellow
try {
    git --version
    Write-Host "Git installation successful!" -ForegroundColor Green
} catch {
    Write-Host "Git verification failed, may need to restart terminal" -ForegroundColor Yellow
}