#!/usr/bin/env python3
"""
密码字典生成器
支持多种模式生成密码字典
"""

import itertools
import string
import argparse
import sys
from datetime import datetime, timedelta

class PasswordGenerator:
    def __init__(self):
        self.common_passwords = [
            "password", "123456", "12345678", "qwerty", "123456789",
            "12345", "1234", "111111", "1234567", "dragon",
            "123123", "baseball", "abc123", "football", "monkey",
            "letmein", "shadow", "master", "666666", "qwertyuiop",
            "123321", "mustang", "1234567890", "michael", "654321",
            "superman", "1qaz2wsx", "7777777", "121212", "000000",
            "admin", "welcome", "login", "pass", "pass123"
        ]
    
    def generate_common(self):
        """生成常见密码"""
        return self.common_passwords
    
    def generate_dates(self, start_year=1980, end_year=2025):
        """生成日期格式密码"""
        passwords = []
        
        # YYYYMMDD 格式
        start_date = datetime(start_year, 1, 1)
        end_date = datetime(end_year, 12, 31)
        current_date = start_date
        
        while current_date <= end_date:
            # YYYYMMDD
            passwords.append(current_date.strftime("%Y%m%d"))
            # YYYY-MM-DD
            passwords.append(current_date.strftime("%Y-%m-%d"))
            # YYYY/MM/DD
            passwords.append(current_date.strftime("%Y/%m/%d"))
            # DDMMYYYY
            passwords.append(current_date.strftime("%d%m%Y"))
            # DD-MM-YYYY
            passwords.append(current_date.strftime("%d-%m-%Y"))
            # DD/MM/YYYY
            passwords.append(current_date.strftime("%d/%m/%Y"))
            # MMDDYYYY
            passwords.append(current_date.strftime("%m%d%Y"))
            
            current_date += timedelta(days=1)
        
        return passwords
    
    def generate_phone_numbers(self, prefixes=None):
        """生成手机号格式密码"""
        if prefixes is None:
            prefixes = ["138", "139", "150", "151", "152", "153", 
                       "155", "156", "157", "158", "159", "186",
                       "187", "188", "189", "130", "131", "132",
                       "133", "134", "135", "136", "137"]
        
        passwords = []
        for prefix in prefixes:
            # 生成后8位数字
            for i in range(100000000):
                phone = f"{prefix}{i:08d}"
                passwords.append(phone)
                if len(passwords) >= 10000:  # 限制数量
                    break
            if len(passwords) >= 10000:
                break
        
        return passwords[:10000]  # 返回前10000个
    
    def generate_leet_speak(self, word):
        """生成 Leet Speak 变体"""
        leet_map = {
            'a': ['a', '4', '@'],
            'b': ['b', '8'],
            'c': ['c'],
            'd': ['d'],
            'e': ['e', '3'],
            'f': ['f'],
            'g': ['g', '9'],
            'h': ['h'],
            'i': ['i', '1', '!'],
            'j': ['j'],
            'k': ['k'],
            'l': ['l', '1', '|'],
            'm': ['m'],
            'n': ['n'],
            'o': ['o', '0'],
            'p': ['p'],
            'q': ['q'],
            'r': ['r'],
            's': ['s', '5', '$'],
            't': ['t', '7'],
            'u': ['u'],
            'v': ['v'],
            'w': ['w'],
            'x': ['x'],
            'y': ['y'],
            'z': ['z', '2']
        }
        
        word = word.lower()
        variations = ['']
        
        for char in word:
            new_variations = []
            for variant in variations:
                if char in leet_map:
                    for leet_char in leet_map[char]:
                        new_variations.append(variant + leet_char)
                else:
                    new_variations.append(variant + char)
            variations = new_variations
        
        return variations
    
    def generate_common_leet(self):
        """生成常见密码的 Leet Speak 变体"""
        passwords = []
        for common in self.common_passwords:
            leet_variants = self.generate_leet_speak(common)
            passwords.extend(leet_variants[:10])  # 限制每个单词10个变体
        
        return passwords
    
    def generate_keyboard_patterns(self):
        """生成键盘模式密码"""
        patterns = [
            # 水平行
            "qwerty", "qwertyuiop", "asdfgh", "asdfghjkl", "zxcvbn", "zxcvbnm",
            # 垂直列
            "qaz", "wsx", "edc", "rfv", "tgb", "yhn", "ujm", "ik", "ol", "p",
            # 对角线
            "1qaz", "2wsx", "3edc", "4rfv", "5tgb", "6yhn", "7ujm", "8ik", "9ol", "0p",
            # 重复
            "qwertyuiop[]", "asdfghjkl;'", "zxcvbnm,./"
        ]
        
        # 添加大小写变体
        expanded = []
        for pattern in patterns:
            expanded.append(pattern)
            expanded.append(pattern.upper())
            expanded.append(pattern.capitalize())
        
        return expanded
    
    def generate_sequential(self, length=6):
        """生成连续数字/字母"""
        passwords = []
        
        # 数字序列
        for i in range(10 - length + 1):
            seq = ''.join(str(j) for j in range(i, i + length))
            passwords.append(seq)
        
        # 字母序列（小写）
        alphabet = string.ascii_lowercase
        for i in range(len(alphabet) - length + 1):
            seq = alphabet[i:i + length]
            passwords.append(seq)
        
        return passwords
    
    def generate_company_names(self):
        """生成公司名相关密码"""
        companies = [
            "microsoft", "google", "apple", "amazon", "facebook",
            "twitter", "instagram", "whatsapp", "telegram", "signal",
            "zoom", "slack", "discord", "github", "gitlab",
            "bitbucket", "jira", "confluence", "trello", "asana"
        ]
        
        passwords = []
        for company in companies:
            passwords.append(company)
            passwords.append(company + "123")
            passwords.append(company.capitalize() + "123")
            passwords.append(company.upper() + "123")
            passwords.append("@" + company)
            passwords.append("#" + company)
        
        return passwords
    
    def generate_special_chars(self, base_words=None):
        """生成带特殊字符的密码"""
        if base_words is None:
            base_words = self.common_passwords
        
        special_chars = ["!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "_", "=", "+"]
        
        passwords = []
        for word in base_words:
            # 前后添加特殊字符
            for char in special_chars:
                passwords.append(char + word)
                passwords.append(word + char)
                passwords.append(char + word + char)
            
            # 替换字母为特殊字符
            if 'a' in word.lower():
                passwords.append(word.lower().replace('a', '@'))
            if 's' in word.lower():
                passwords.append(word.lower().replace('s', '$'))
            if 'i' in word.lower():
                passwords.append(word.lower().replace('i', '!'))
            if 'o' in word.lower():
                passwords.append(word.lower().replace('o', '0'))
        
        return passwords
    
    def generate_all(self, max_count=100000):
        """生成所有类型的密码"""
        all_passwords = []
        
        # 添加各种类型的密码
        all_passwords.extend(self.generate_common())
        all_passwords.extend(self.generate_common_leet())
        all_passwords.extend(self.generate_keyboard_patterns())
        all_passwords.extend(self.generate_sequential())
        all_passwords.extend(self.generate_company_names())
        all_passwords.extend(self.generate_special_chars())
        
        # 去重
        unique_passwords = list(dict.fromkeys(all_passwords))
        
        # 限制数量
        return unique_passwords[:max_count]
    
    def save_to_file(self, passwords, filename):
        """保存密码到文件"""
        with open(filename, 'w', encoding='utf-8') as f:
            for password in passwords:
                f.write(password + '\n')
        
        print(f"已生成 {len(passwords)} 个密码到 {filename}")

def main():
    parser = argparse.ArgumentParser(description='密码字典生成器')
    parser.add_argument('output', help='输出文件名')
    parser.add_argument('--type', choices=['all', 'common', 'dates', 'phone', 'leet', 
                                          'keyboard', 'sequential', 'company', 'special'],
                       default='all', help='生成类型')
    parser.add_argument('--max', type=int, default=100000, help='最大密码数量')
    
    args = parser.parse_args()
    
    generator = PasswordGenerator()
    
    if args.type == 'all':
        passwords = generator.generate_all(args.max)
    elif args.type == 'common':
        passwords = generator.generate_common()
    elif args.type == 'dates':
        passwords = generator.generate_dates()
    elif args.type == 'phone':
        passwords = generator.generate_phone_numbers()
    elif args.type == 'leet':
        passwords = generator.generate_common_leet()
    elif args.type == 'keyboard':
        passwords = generator.generate_keyboard_patterns()
    elif args.type == 'sequential':
        passwords = generator.generate_sequential()
    elif args.type == 'company':
        passwords = generator.generate_company_names()
    elif args.type == 'special':
        passwords = generator.generate_special_chars()
    else:
        print("错误: 未知类型")
        sys.exit(1)
    
    # 限制数量
    passwords = passwords[:args.max]
    
    # 保存文件
    generator.save_to_file(passwords, args.output)

if __name__ == "__main__":
    main()