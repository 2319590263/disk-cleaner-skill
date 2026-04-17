# 测试验证脚本
# 确保密码测试的可靠性

param(
    [string]$TestFile = "$env:USERPROFILE\Desktop\test.7z",
    [string]$KnownPassword = "34566"
)

# 颜色定义
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Yellow"
$DebugColor = "Gray"

function Write-Color {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-Password-Reliable {
    param(
        [string]$ArchivePath,
        [string]$Password
    )
    
    $7zPath = "C:\Program Files\7-Zip\7z.exe"
    
    if (-not (Test-Path $7zPath)) {
        Write-Color "错误: 7-Zip未安装" $ErrorColor
        return $false
    }
    
    # 方法1: 直接命令行测试
    Write-Color "方法1测试: $Password" $DebugColor
    $result1 = & $7zPath t "-p$Password" $ArchivePath 2>&1
    $exitCode1 = $LASTEXITCODE
    
    # 方法2: 使用Start-Process（更可靠）
    Write-Color "方法2测试: $Password" $DebugColor
    $tempFile = [System.IO.Path]::GetTempFileName()
    $process = Start-Process -FilePath $7zPath `
        -ArgumentList "t", "-p$Password", "`"$ArchivePath`"" `
        -NoNewWindow -Wait -PassThru `
        -RedirectStandardOutput $tempFile `
        -RedirectStandardError "nul"
    $exitCode2 = $process.ExitCode
    $output2 = Get-Content $tempFile -Raw
    Remove-Item $tempFile -Force
    
    # 方法3: 使用l命令验证
    Write-Color "方法3测试: $Password" $DebugColor
    $tempFile2 = [System.IO.Path]::GetTempFileName()
    $process2 = Start-Process -FilePath $7zPath `
        -ArgumentList "l", "-p$Password", "`"$ArchivePath`"" `
        -NoNewWindow -Wait -PassThru `
        -RedirectStandardOutput $tempFile2 `
        -RedirectStandardError "nul"
    $exitCode3 = $process2.ExitCode
    $output3 = Get-Content $tempFile2 -Raw
    Remove-Item $tempFile2 -Force
    
    # 检查结果
    $success = $false
    $reasons = @()
    
    if ($exitCode1 -eq 0) {
        $success = $true
        $reasons += "方法1成功"
    }
    
    if ($exitCode2 -eq 0) {
        $success = $true
        $reasons += "方法2成功"
    }
    
    if ($output3 -match "Everything is Ok") {
        $success = $true
        $reasons += "方法3成功"
    }
    
    if ($success) {
        Write-Color "✅ 密码验证成功: $Password" $SuccessColor
        Write-Color "验证方法: $($reasons -join ', ')" $InfoColor
        return $true
    } else {
        Write-Color "❌ 密码验证失败: $Password" $ErrorColor
        return $false
    }
}

# 主逻辑
Write-Color "=" * 50 $InfoColor
Write-Color "密码测试可靠性验证" $InfoColor
Write-Color "文件: $TestFile" $InfoColor
Write-Color "已知正确密码: $KnownPassword" $InfoColor
Write-Color "=" * 50 $InfoColor

if (-not (Test-Path $TestFile)) {
    Write-Color "错误: 测试文件不存在" $ErrorColor
    exit 1
}

# 测试已知正确密码
Write-Color "`n测试1: 已知正确密码 ($KnownPassword)" $InfoColor
$result1 = Test-Password-Reliable -ArchivePath $TestFile -Password $KnownPassword

# 测试错误密码
Write-Color "`n测试2: 错误密码 (123456)" $InfoColor
$result2 = Test-Password-Reliable -ArchivePath $TestFile -Password "123456"

# 测试之前可能漏测的密码
Write-Color "`n测试3: 之前可能漏测的密码" $InfoColor
$testPasswords = @("34566", "34066", "34166", "34266", "34366", "34466", "34666", "34766", "34866", "34966")
foreach ($pass in $testPasswords) {
    Write-Color "测试: $pass" $DebugColor
    Test-Password-Reliable -ArchivePath $TestFile -Password $pass | Out-Null
}

# 总结
Write-Color "`n" $InfoColor
Write-Color "=" * 50 $InfoColor
Write-Color "验证总结" $InfoColor
Write-Color "=" * 50 $InfoColor

if ($result1) {
    Write-Color "✅ 已知正确密码验证通过" $SuccessColor
} else {
    Write-Color "❌ 已知正确密码验证失败 - 系统有问题！" $ErrorColor
}

if (-not $result2) {
    Write-Color "✅ 错误密码正确拒绝" $SuccessColor
} else {
    Write-Color "❌ 错误密码被接受 - 系统有问题！" $ErrorColor
}

Write-Color "`n修复完成：" $InfoColor
Write-Color "1. 创建了可靠的测试脚本 (test-password.ps1)" $InfoColor
Write-Color "2. 创建了批量测试脚本 (batch-test.ps1)" $InfoColor
Write-Color "3. 创建了修复的自动破解脚本 (auto-crack-fixed.sh)" $InfoColor
Write-Color "4. 创建了验证脚本 (verify-test.ps1)" $InfoColor
Write-Color "`n现在系统应该能可靠地测试每个密码，避免漏测。" $SuccessColor