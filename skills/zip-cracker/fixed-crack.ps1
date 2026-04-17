# 修复的压缩包破解脚本
# 解决文件路径编码问题

param(
    [string]$ArchivePath,
    [string]$Password,
    [string]$7zPath = "C:\Program Files\7-Zip\7z.exe"
)

function Get-SafeFilePath {
    param([string]$Path)
    
    # 如果路径包含中文字符，使用文件查找方法
    if ($Path -match "[^\x00-\x7F]") {
        $dir = Split-Path $Path -Parent
        $name = Split-Path $Path -Leaf
        
        if (Test-Path $dir) {
            $files = Get-ChildItem $dir -Filter $name -ErrorAction SilentlyContinue
            if ($files.Count -gt 0) {
                return $files[0].FullName
            }
        }
    }
    
    # 否则返回原路径
    return $Path
}

function Test-Password-Safe {
    param(
        [string]$ArchivePath,
        [string]$Password,
        [string]$7zPath
    )
    
    # 获取安全的文件路径
    $safePath = Get-SafeFilePath $ArchivePath
    
    if (-not (Test-Path $safePath)) {
        Write-Host "错误: 文件不存在 - $ArchivePath" -ForegroundColor Red
        return $false
    }
    
    if (-not (Test-Path $7zPath)) {
        Write-Host "错误: 7-Zip未安装 - $7zPath" -ForegroundColor Red
        return $false
    }
    
    # 测试密码
    $process = Start-Process -FilePath $7zPath `
        -ArgumentList "t", "-p$Password", "`"$safePath`"" `
        -NoNewWindow -Wait -PassThru `
        -RedirectStandardOutput "nul" `
        -RedirectStandardError "nul"
    
    return $process.ExitCode -eq 0
}

function Batch-Test-Passwords {
    param(
        [string]$ArchivePath,
        [string[]]$Passwords,
        [string]$7zPath = "C:\Program Files\7-Zip\7z.exe"
    )
    
    Write-Host "批量测试密码..." -ForegroundColor Cyan
    Write-Host "文件: $(Split-Path $ArchivePath -Leaf)" -ForegroundColor Gray
    Write-Host "密码数量: $($Passwords.Count)" -ForegroundColor Gray
    Write-Host "=" * 50 -ForegroundColor Cyan
    
    $safePath = Get-SafeFilePath $ArchivePath
    
    if (-not (Test-Path $safePath)) {
        Write-Host "❌ 文件不存在: $ArchivePath" -ForegroundColor Red
        return $null
    }
    
    $found = $false
    $tested = 0
    
    foreach ($password in $Passwords) {
        $tested++
        Write-Host "测试 [$tested/$($Passwords.Count)]: $password" -NoNewline
        
        if (Test-Password-Safe -ArchivePath $safePath -Password $password -7zPath $7zPath) {
            Write-Host "`r✅ 找到密码: $password" -ForegroundColor Green
            $found = $true
            return $password
        }
        
        Write-Host "`r" -NoNewline
        
        # 每10个显示一次进度
        if ($tested % 10 -eq 0) {
            Write-Host "进度: $tested/$($Passwords.Count)" -ForegroundColor DarkYellow
        }
    }
    
    if (-not $found) {
        Write-Host "`n❌ 未找到正确密码" -ForegroundColor Red
    }
    
    return $null
}

# 示例：测试两位数密码
function Test-TwoDigitPasswords {
    param([string]$ArchivePath)
    
    Write-Host "测试所有两位数密码 (00-99)..." -ForegroundColor Yellow
    
    $passwords = @()
    for ($i = 0; $i -le 99; $i++) {
        $passwords += $i.ToString("00")
    }
    
    $result = Batch-Test-Passwords -ArchivePath $ArchivePath -Passwords $passwords
    
    if ($result) {
        Write-Host "✅ 找到密码: $result" -ForegroundColor Green
        return $result
    } else {
        Write-Host "❌ 所有两位数密码尝试失败" -ForegroundColor Red
        return $null
    }
}

# 主函数
if ($MyInvocation.InvocationName -ne '.') {
    # 如果直接运行脚本
    if ($PSBoundParameters.ContainsKey('ArchivePath')) {
        if ($PSBoundParameters.ContainsKey('Password')) {
            # 测试单个密码
            if (Test-Password-Safe -ArchivePath $ArchivePath -Password $Password -7zPath $7zPath) {
                Write-Host "✅ 密码正确: $Password" -ForegroundColor Green
                exit 0
            } else {
                Write-Host "❌ 密码错误: $Password" -ForegroundColor Red
                exit 1
            }
        } else {
            # 批量测试
            Test-TwoDigitPasswords -ArchivePath $ArchivePath
        }
    } else {
        Write-Host "用法: .\fixed-crack.ps1 <压缩文件> [密码]" -ForegroundColor Yellow
        Write-Host "示例: .\fixed-crack.ps1 secret.zip" -ForegroundColor Gray
        Write-Host "示例: .\fixed-crack.ps1 secret.zip 12345" -ForegroundColor Gray
    }
}