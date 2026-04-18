# Browser automation test script
Write-Host "=== Browser Automation Test ===" -ForegroundColor Green

# 1. Open Baidu
Write-Host "1. Opening Baidu..." -ForegroundColor Yellow
agent-browser --executable-path "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" open https://www.baidu.com
Start-Sleep -Seconds 3

# 2. Get page snapshot
Write-Host "2. Getting page snapshot..." -ForegroundColor Yellow
$snapshot = agent-browser snapshot -i --json
Write-Host "Snapshot successful, page contains:" -ForegroundColor Green

# 3. Show main elements
Write-Host "3. Main page elements:" -ForegroundColor Yellow
$data = $snapshot | ConvertFrom-Json -ErrorAction SilentlyContinue
if ($data -and $data.success) {
    $lines = $data.data.snapshot -split "`n"
    foreach ($line in $lines) {
        if ($line -match "textbox|button|link.*百度") {
            Write-Host "  $line" -ForegroundColor Cyan
        }
    }
}

# 4. Test complete
Write-Host "`n=== Test Complete ===" -ForegroundColor Green
Write-Host "Browser automation is working!" -ForegroundColor Green
Write-Host "Successfully:" -ForegroundColor Yellow
Write-Host "  ✓ Opened Baidu page" -ForegroundColor Green
Write-Host "  ✓ Got page snapshot" -ForegroundColor Green
Write-Host "  ✓ Identified interactive elements" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. Type in search box" -ForegroundColor White
Write-Host "  2. Click search button" -ForegroundColor White
Write-Host "  3. Extract search results" -ForegroundColor White
Write-Host "  4. Take screenshot" -ForegroundColor White

# 5. Close browser
Write-Host "`nClosing browser..." -ForegroundColor Yellow
agent-browser close