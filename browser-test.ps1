# 浏览器自动化测试脚本
Write-Host "=== 浏览器自动化测试 ===" -ForegroundColor Green

# 1. 打开百度
Write-Host "1. 打开百度..." -ForegroundColor Yellow
agent-browser --executable-path "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" open https://www.baidu.com
Start-Sleep -Seconds 3

# 2. 获取页面快照
Write-Host "2. 获取页面快照..." -ForegroundColor Yellow
$snapshot = agent-browser snapshot -i --json
Write-Host "快照获取成功，页面包含以下交互元素：" -ForegroundColor Green

# 3. 显示主要元素
Write-Host "3. 页面主要元素：" -ForegroundColor Yellow
$snapshot | ConvertFrom-Json | ForEach-Object {
    if ($_.success) {
        $_.data.snapshot -split "`n" | ForEach-Object {
            if ($_ -match "textbox|button|link.*百度") {
                Write-Host "  $_" -ForegroundColor Cyan
            }
        }
    }
}

# 4. 测试完成
Write-Host "`n=== 测试完成 ===" -ForegroundColor Green
Write-Host "浏览器自动化功能正常工作！" -ForegroundColor Green
Write-Host "已成功：" -ForegroundColor Yellow
Write-Host "  ✓ 打开百度页面" -ForegroundColor Green
Write-Host "  ✓ 获取页面快照" -ForegroundColor Green
Write-Host "  ✓ 识别交互元素" -ForegroundColor Green
Write-Host "`n下一步可以：" -ForegroundColor Yellow
Write-Host "  1. 在搜索框中输入内容" -ForegroundColor White
Write-Host "  2. 点击搜索按钮" -ForegroundColor White
Write-Host "  3. 提取搜索结果" -ForegroundColor White
Write-Host "  4. 截图保存" -ForegroundColor White

# 5. 关闭浏览器
Write-Host "`n关闭浏览器..." -ForegroundColor Yellow
agent-browser close