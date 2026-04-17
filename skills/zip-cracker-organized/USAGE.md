# zip-cracker 技能使用说明

## 🚀 快速开始

### 安装依赖
`ash
# Linux/macOS
chmod +x scripts/install-tools.sh
./scripts/install-tools.sh

# Windows
powershell -ExecutionPolicy Bypass -File scripts\install-tools.ps1
`

### 基本使用
`ash
# 自动破解
./scripts/auto-crack-fixed.sh encrypted.zip

# 生成密码字典
python3 generate-wordlists.py custom-dict.txt --type=all --max=50000

# 批量测试密码
powershell -ExecutionPolicy Bypass -File scripts\batch-test.ps1 encrypted.zip
`

## 🔧 修复内容

### 已解决的问题
1. **文件路径编码问题** - 支持中文字符路径
2. **密码参数解析问题** - 正确处理单个数字密码
3. **静默失败问题** - 完善的错误处理

### 核心修复代码
`powershell
# ❌ 旧方法（有问题）
7z t -p$pass "C:\Users\...\中文文件.zip"

# ✅ 新方法（修复后）
$file = Get-ChildItem "C:\Users\...\*.zip" | Select-Object -First 1
7z t -p"$pass" $file.FullName
`

## 📊 功能特性

### 支持的格式
- ZIP (完全支持)
- RAR (需要额外工具)
- 7Z (完全支持)
- 其他常见格式

### 破解方法 (12种)
1. 快速尝试常用密码
2. 字典攻击
3. 暴力破解
4. Hashcat GPU加速
5. RAR专用破解
6. 7z专用破解
7. 密码生成器攻击
8. 网站爬取字典
9. 分布式破解
10. 彩虹表攻击
11. 掩码攻击
12. 组合攻击

## ⚠️ 法律声明
本技能仅供学习和合法用途，禁止用于非法活动。
