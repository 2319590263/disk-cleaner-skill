---
name: zip_cracker
description: 处理压缩包密码破解和恢复相关任务
requires:
  - tools: ["exec", "read", "write", "edit", "glob", "grep"]
  - binaries: ["7z", "fcrackzip", "john", "hashcat", "rar", "unrar", "zip", "unzip", "crunch", "cewl", "hydra", "medusa", "ncrack", "patator", "aircrack-ng", "pyrit", "rainbowcrack", "ophcrack"]
  - os: ["linux", "macos", "windows", "wsl", "cygwin"]
---

# 压缩包破解技能

当用户需要处理受密码保护的压缩文件时，使用此技能。

## 适用场景

- 忘记压缩包密码
- 需要测试压缩包安全性
- 恢复丢失的密码
- 安全测试

## 工具准备

### 1. 安装必要工具

**Linux (Debian/Ubuntu):**
```bash
sudo apt-get update
sudo apt-get install p7zip-full fcrackzip john hashcat
```

**macOS:**
```bash
brew install p7zip fcrackzip john-jumbo hashcat
```

**Windows:**
- 下载 7-Zip: https://www.7-zip.org/
- 下载 fcrackzip (通过 WSL 或 Cygwin)
- 下载 John the Ripper: https://www.openwall.com/john/
- 下载 Hashcat: https://hashcat.net/hashcat/
- 下载 RAR: https://www.rarlab.com/
- 下载 Crunch: https://sourceforge.net/projects/crunch-wordlist/
- 下载 CeWL: https://github.com/digininja/CeWL
- 下载 Hydra: https://github.com/vanhauser-thc/thc-hydra
- 下载 Aircrack-ng: https://www.aircrack-ng.org/
- 下载 RainbowCrack: http://project-rainbowcrack.com/

### 2. 基本检查

首先检查压缩包信息：
```bash
# 查看压缩包内容
7z l archive.zip

# 测试是否需要密码
7z t archive.zip
```

## 破解方法

### 方法1: 字典攻击 (推荐)

1. **准备密码字典:**
```bash
# 常用密码字典
cat > passwords.txt << EOF
password
123456
qwerty
admin
letmein
welcome
<用户提供的可能密码>
EOF
```

2. **使用 fcrackzip:**
```bash
fcrackzip -v -D -p passwords.txt -u archive.zip
```

3. **使用 7z + 脚本:**
```bash
while read pass; do
  7z t -p"$pass" archive.zip 2>/dev/null && echo "密码找到: $pass" && break
done < passwords.txt
```

### 方法2: 暴力破解

**简单模式 (数字):**
```bash
fcrackzip -v -c a -l 4-6 archive.zip  # 4-6位小写字母
fcrackzip -v -c 1 -l 4-6 archive.zip  # 4-6位数字
```

**组合模式:**
```bash
fcrackzip -v -c aA1 -l 6-8 archive.zip  # 大小写字母+数字
```

### 方法3: 使用 John the Ripper

1. **提取哈希:**
```bash
zip2john archive.zip > hash.txt
```

2. **破解哈希:**
```bash
# 字典攻击
john --wordlist=passwords.txt hash.txt

# 显示找到的密码
john --show hash.txt
```

### 方法4: 使用 Hashcat (GPU加速)

### 方法5: RAR 压缩包破解

**RAR 专用工具:**
```bash
# 使用 rar2john 提取哈希
rar2john archive.rar > rar_hash.txt

# 使用 John 破解
john --wordlist=passwords.txt rar_hash.txt

# 使用 hashcat (模式 13000)
hashcat -m 13000 rar_hash.txt passwords.txt

# 直接使用 unrar 尝试
unrar t -p密码 archive.rar
```

### 方法6: 7z 压缩包破解

**7z 专用方法:**
```bash
# 使用 7z2john 提取哈希 (需要脚本)
git clone https://github.com/magnumripper/JohnTheRipper.git
cd JohnTheRipper/run
./7z2john.pl archive.7z > 7z_hash.txt

# 使用 John 破解
john --wordlist=passwords.txt 7z_hash.txt

# 批量尝试脚本
for pass in $(cat passwords.txt); do
  7z t -p"$pass" archive.7z >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "密码找到: $pass"
    break
  fi
done
```

### 方法7: 密码生成器 + 破解

**使用 Crunch 生成密码字典:**
```bash
# 生成数字密码 (4-6位)
crunch 4 6 0123456789 -o num_passwords.txt

# 生成字母密码 (小写，4-6位)
crunch 4 6 abcdefghijklmnopqrstuvwxyz -o alpha_passwords.txt

# 生成混合密码 (大小写+数字，6-8位)
crunch 6 8 -f /usr/share/crunch/charset.lst mixalpha-numeric -o mixed_passwords.txt

# 使用生成的字典
fcrackzip -v -D -p mixed_passwords.txt -u archive.zip
```

### 方法8: 网站爬取密码字典

**使用 CeWL 从网站生成字典:**
```bash
# 从目标网站爬取单词
cewl -d 2 -m 5 -w site_words.txt https://example.com

# 添加常见变体
cewl -d 2 -m 5 -w site_words.txt --with-numbers https://example.com

# 使用爬取的字典
fcrackzip -v -D -p site_words.txt -u archive.zip
```

### 方法9: 分布式破解

**使用多个工具并行:**
```bash
# 同时使用多个字典
fcrackzip -v -D -p dict1.txt -u archive.zip &
fcrackzip -v -D -p dict2.txt -u archive.zip &
fcrackzip -v -D -p dict3.txt -u archive.zip &
wait

# 使用不同字符集同时破解
fcrackzip -v -c a -l 4-6 archive.zip &
fcrackzip -v -c 1 -l 4-6 archive.zip &
fcrackzip -v -c a1 -l 4-6 archive.zip &
wait
```

### 方法10: 彩虹表攻击

**使用 RainbowCrack:**
```bash
# 生成彩虹表
rtgen zip plaintext_len_min plaintext_len_max charset_index

# 排序彩虹表
rtsort rainbow_table.rt

# 使用彩虹表破解
rcrack rainbow_table.rt -h zip_hash
```

### 方法11: 掩码攻击

**智能掩码模式:**
```bash
# 使用 hashcat 掩码攻击
# ?l = 小写字母, ?u = 大写字母, ?d = 数字, ?s = 特殊字符

# 常见模式: 首字母大写+数字
hashcat -m 13600 -a 3 hash.txt ?u?l?l?l?l?d?d?d

# 手机号模式
hashcat -m 13600 -a 3 hash.txt 1?d?d?d?d?d?d?d?d?d

# 日期模式: 20250101
hashcat -m 13600 -a 3 hash.txt 202?d?d?d?d

# 自定义掩码
hashcat -m 13600 -a 3 hash.txt -1 ?l?d ?1?1?1?1?1?1
```

### 方法12: 组合攻击

**字典+规则组合:**
```bash
# 使用 John 的规则系统
john --wordlist=passwords.txt --rules:Single hash.txt
john --wordlist=passwords.txt --rules:Wordlist hash.txt
john --wordlist=passwords.txt --rules:Extra hash.txt

# 使用 hashcat 规则
hashcat -m 13600 -a 0 hash.txt passwords.txt -r /usr/share/hashcat/rules/best64.rule
hashcat -m 13600 -a 0 hash.txt passwords.txt -r /usr/share/hashcat/rules/rockyou-30000.rule
hashcat -m 13600 -a 0 hash.txt passwords.txt -r /usr/share/hashcat/rules/d3ad0ne.rule

# 多重规则串联
hashcat -m 13600 -a 0 hash.txt passwords.txt -r rules/best64.rule -r rules/leetspeak.rule
```

1. **提取哈希:**
```bash
zip2john archive.zip | cut -d ':' -f 2 > hash.txt
```

2. **破解:**
```bash
# 字典攻击
hashcat -m 13600 hash.txt passwords.txt

# 暴力破解数字
hashcat -m 13600 -a 3 hash.txt ?d?d?d?d
```

## 最佳实践

1. **先尝试已知密码:**
   - 常用密码变体
   - 个人信息组合
   - 历史使用密码

2. **合理设置参数:**
   - 优先字典攻击
   - 限制暴力破解长度
   - 考虑计算资源

3. **备份重要文件:**
   - 破解前备份原文件
   - 防止数据损坏
   - 记录尝试过程

## 故障排除

### 常见问题

1. **工具未找到:**
   ```bash
   # 检查安装
   which 7z fcrackzip john hashcat
   ```

2. **权限问题:**
   ```bash
   chmod +x tools/*
   sudo apt-get install <package>
   ```

3. **内存不足:**
   - 减小字典大小
   - 分批处理
   - 使用更高效算法

## 示例命令

```bash
# 完整示例：字典攻击
fcrackzip -v -D -p ~/wordlists/rockyou.txt -u important.zip

# 简单暴力破解
fcrackzip -v -c a1 -l 4-6 document.zip

# 使用自定义规则
john --wordlist=passwords.txt --rules hash.txt
```

## 高级技巧

### GPU 优化配置

**NVIDIA GPU:**
```bash
# 查看GPU信息
hashcat -I

# 优化性能
hashcat -m 13600 -w 4 -d 1 hash.txt passwords.txt  # 高性能模式
hashcat -m 13600 -w 3 -d 1 hash.txt passwords.txt  # 平衡模式
hashcat -m 13600 -w 2 -d 1 hash.txt passwords.txt  # 节能模式
```

**AMD GPU:**
```bash
# 使用 OpenCL
hashcat -m 13600 -d 2 hash.txt passwords.txt
```

### 云破解服务

**在线破解平台:**
- [GPUHack.me](https://gpuhack.me) - GPU云破解
- [OnlineHashCrack](https://www.onlinehashcrack.com) - 在线密码破解
- [CrackStation](https://crackstation.net) - 大型彩虹表

### 自动化脚本

**Python 自动化:**
```python
#!/usr/bin/env python3
import subprocess
import itertools
import string

# 简单暴力破解
def brute_force_zip(zip_file, max_length=6):
    chars = string.digits + string.ascii_lowercase
    for length in range(1, max_length + 1):
        for attempt in itertools.product(chars, repeat=length):
            password = ''.join(attempt)
            result = subprocess.run(
                ['7z', 't', f'-p{password}', zip_file],
                capture_output=True
            )
            if result.returncode == 0:
                return password
    return None
```

**Bash 自动化:**
```bash
#!/bin/bash
# 自动破解脚本
auto_crack() {
    local file="$1"
    echo "开始破解: $file"
    
    # 尝试常用密码
    for pass in "password" "123456" "qwerty" "admin"; do
        7z t -p"$pass" "$file" 2>/dev/null && echo "快速找到: $pass" && return
    done
    
    # 字典攻击
    fcrackzip -D -p passwords.txt -u "$file"
    
    # 暴力破解后备
    fcrackzip -c a1 -l 4-6 "$file"
}
```

## 参考资料

- [fcrackzip 手册](https://manpages.debian.org/testing/fcrackzip/fcrackzip.1.en.html)
- [John the Ripper 文档](https://www.openwall.com/john/doc/)
- [Hashcat 指南](https://hashcat.net/wiki/)
- [7-Zip 命令行](https://sevenzip.osdn.jp/chm/cmdline/)
- [RAR 实验室](https://www.rarlab.com/technote.htm)
- [Crunch 手册](https://tools.kali.org/password-attacks/crunch)
- [CeWL 文档](https://github.com/digininja/CeWL)
- [Hydra 手册](https://github.com/vanhauser-thc/thc-hydra)
- [RainbowCrack 指南](http://project-rainbowcrack.com/)
- [Aircrack-ng 文档](https://www.aircrack-ng.org/doku.php)
- [密码学安全指南](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)

---
