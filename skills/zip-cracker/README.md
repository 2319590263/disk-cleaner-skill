# 压缩包破解技能

这是一个OpenClaw技能，用于处理压缩包密码破解和恢复相关任务。

## 功能

- 检查压缩包信息
- 字典攻击破解
- 暴力破解
- 使用专业工具（John the Ripper, Hashcat）
- 密码恢复策略

## 文件结构

```
zip-cracker/
├── SKILL.md                  # 技能主文件
├── password-list.txt         # 基础密码字典 (300+)
├── advanced-passwords.txt    # 高级密码字典 (4000+)
├── auto-crack.sh             # 自动破解脚本
├── generate-wordlists.py     # 密码字典生成器
├── install-tools.sh          # 工具安装脚本
└── README.md                 # 说明文件
```

## 使用方法

1. **确保工具已安装:**
   - 7-Zip (7z)
   - fcrackzip
   - John the Ripper
   - Hashcat (可选，GPU加速)

2. **基本命令:**
   ```bash
   # 检查压缩包
   7z l archive.zip
   
   # 字典攻击
   fcrackzip -v -D -p password-list.txt -u archive.zip
   
   # 暴力破解数字密码
   fcrackzip -v -c 1 -l 4-6 archive.zip
   ```

3. **高级用法:**
   ```bash
   # 提取哈希
   zip2john archive.zip > hash.txt
   
   # 使用John破解
   john --wordlist=password-list.txt hash.txt
   
   # 显示结果
   john --show hash.txt
   ```

## 工具安装

### Windows
1. 下载并安装 7-Zip
2. 安装 WSL 或 Cygwin 获取 Linux 工具
3. 下载 John the Ripper Windows版

### Linux
```bash
sudo apt-get update
sudo apt-get install p7zip-full fcrackzip john hashcat
```

### macOS
```bash
brew install p7zip fcrackzip john-jumbo hashcat
```
## 注意事项

1. **备份重要文件** - 破解前先备份
2. **合理使用资源** - 暴力破解耗资源
3. **遵守法律** - 仅限合法用途
4. **教育目的** - 主要用于学习

## 性能优化

1. **优先字典攻击** - 成功率较高
2. **限制破解长度** - 避免无限循环
3. **使用GPU加速** - Hashcat支持
4. **分批处理** - 大字典分块

## 故障排除

- **工具未找到**: 检查安装路径
- **权限问题**: 使用sudo或管理员权限
- **内存不足**: 减小字典或分批
- **格式不支持**: 检查压缩格式

## 支持格式

- **ZIP** - 完全支持 (fcrackzip, John, Hashcat)
- **RAR** - 完全支持 (rar2john, Hashcat模式13000)
- **7Z** - 支持 (7z2john, 7z命令行)
- **GZIP/TAR** - 基础支持
- **其他格式** - 通用方法支持

## 破解方法 (12种)

1. **快速尝试** - 常用密码快速测试
2. **字典攻击** - 使用密码字典
3. **暴力破解** - 尝试所有组合
4. **Hashcat GPU加速** - 高性能破解
5. **RAR专用破解** - RAR格式优化
6. **7z专用破解** - 7z格式优化
7. **密码生成器攻击** - 动态生成字典
8. **网站爬取字典** - 从目标网站生成字典
9. **分布式破解** - 多工具并行
10. **彩虹表攻击** - 预计算哈希
11. **掩码攻击** - 智能模式匹配
12. **组合攻击** - 字典+规则组合

## 更新日志

- **v2.0.0**: 强化版本
  - 增加12种破解方法
  - 新增6种工具支持
  - 添加自动化脚本
  - 扩展密码字典
  - 支持GPU加速

- **v1.0.0**: 初始版本
  - 基础破解功能
  - 常用密码字典
  - 多工具支持
