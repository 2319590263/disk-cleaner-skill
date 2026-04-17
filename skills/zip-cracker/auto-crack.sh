#!/bin/bash
# 自动压缩包破解脚本
# 支持多种格式和多种攻击方式

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查工具是否安装
check_tool() {
    if ! command -v $1 &> /dev/null; then
        log_error "工具 $1 未安装"
        return 1
    fi
    log_info "工具 $1 已安装"
    return 0
}

# 检查压缩包格式
detect_format() {
    local file="$1"
    local extension="${file##*.}"
    
    case "${extension,,}" in
        zip)
            echo "zip"
            ;;
        rar)
            echo "rar"
            ;;
        7z)
            echo "7z"
            ;;
        gz|tar.gz|tgz)
            echo "gzip"
            ;;
        bz2|tar.bz2)
            echo "bzip2"
            ;;
        xz|tar.xz)
            echo "xz"
            ;;
        *)
            log_warning "未知格式: $extension，尝试通用方法"
            echo "unknown"
            ;;
    esac
}

# 快速尝试常用密码
quick_try() {
    local file="$1"
    local format="$2"
    
    log_info "开始快速尝试常用密码..."
    
    local quick_passwords=(
        "password" "123456" "12345678" "qwerty" "123456789"
        "12345" "1234" "111111" "1234567" "dragon"
        "123123" "baseball" "abc123" "football" "monkey"
        "letmein" "shadow" "master" "666666" "qwertyuiop"
        "123321" "mustang" "1234567890" "michael" "654321"
        "superman" "1qaz2wsx" "7777777" "121212" "000000"
        ""  # 空密码
    )
    
    for pass in "${quick_passwords[@]}"; do
        log_info "尝试密码: '$pass'"
        
        case "$format" in
            zip)
                7z t -p"$pass" "$file" >/dev/null 2>&1
                ;;
            rar)
                unrar t -p"$pass" "$file" >/dev/null 2>&1
                ;;
            7z)
                7z t -p"$pass" "$file" >/dev/null 2>&1
                ;;
            *)
                7z t -p"$pass" "$file" >/dev/null 2>&1
                ;;
        esac
        
        if [ $? -eq 0 ]; then
            log_success "找到密码: $pass"
            echo "$pass"
            return 0
        fi
    done
    
    log_warning "快速尝试未找到密码"
    return 1
}

# 字典攻击
dictionary_attack() {
    local file="$1"
    local format="$2"
    local dict_file="${3:-passwords.txt}"
    
    log_info "开始字典攻击，使用字典: $dict_file"
    
    if [ ! -f "$dict_file" ]; then
        log_error "字典文件不存在: $dict_file"
        return 1
    fi
    
    case "$format" in
        zip)
            fcrackzip -v -D -p "$dict_file" -u "$file"
            if [ $? -eq 0 ]; then
                return 0
            fi
            ;;
        *)
            # 通用方法
            while IFS= read -r pass || [ -n "$pass" ]; do
                log_info "尝试密码: $pass"
                7z t -p"$pass" "$file" >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    log_success "找到密码: $pass"
                    echo "$pass"
                    return 0
                fi
            done < "$dict_file"
            ;;
    esac
    
    log_warning "字典攻击未找到密码"
    return 1
}

# 暴力破解
brute_force() {
    local file="$1"
    local format="$2"
    local charset="$3"
    local min_len="$4"
    local max_len="$5"
    
    log_info "开始暴力破解: 字符集=$charset, 长度=$min_len-$max_len"
    
    case "$format" in
        zip)
            fcrackzip -v -c "$charset" -l "$min_len-$max_len" -u "$file"
            ;;
        *)
            log_warning "格式 $format 的暴力破解需要手动实现"
            return 1
            ;;
    esac
}

# 使用 John the Ripper
john_attack() {
    local file="$1"
    local format="$2"
    
    log_info "使用 John the Ripper 攻击"
    
    # 提取哈希
    local hash_file="hash_$(date +%s).txt"
    
    case "$format" in
        zip)
            zip2john "$file" > "$hash_file"
            ;;
        rar)
            rar2john "$file" > "$hash_file"
            ;;
        7z)
            # 需要 7z2john 脚本
            if [ -f "7z2john.pl" ]; then
                ./7z2john.pl "$file" > "$hash_file"
            else
                log_error "7z2john.pl 脚本未找到"
                return 1
            fi
            ;;
        *)
            log_error "不支持格式: $format"
            return 1
            ;;
    esac
    
    if [ ! -s "$hash_file" ]; then
        log_error "哈希提取失败"
        rm -f "$hash_file"
        return 1
    fi
    
    log_info "哈希提取完成: $hash_file"
    
    # 使用 John 破解
    log_info "开始 John 破解..."
    john --wordlist=passwords.txt "$hash_file"
    
    # 显示结果
    log_info "破解结果:"
    john --show "$hash_file"
    
    # 清理
    rm -f "$hash_file"
    return 0
}

# 主函数
main() {
    if [ $# -lt 1 ]; then
        echo "用法: $0 <压缩文件> [字典文件]"
        echo "示例: $0 secret.zip passwords.txt"
        exit 1
    fi
    
    local target_file="$1"
    local dict_file="${2:-passwords.txt}"
    
    if [ ! -f "$target_file" ]; then
        log_error "文件不存在: $target_file"
        exit 1
    fi
    
    log_info "目标文件: $target_file"
    
    # 检测格式
    local format=$(detect_format "$target_file")
    log_info "检测到格式: $format"
    
    # 检查必要工具
    case "$format" in
        zip)
            check_tool "7z" || check_tool "unzip"
            check_tool "fcrackzip"
            ;;
        rar)
            check_tool "unrar" || check_tool "rar"
            ;;
        7z)
            check_tool "7z"
            ;;
        *)
            check_tool "7z"
            ;;
    esac
    
    check_tool "john" || log_warning "John the Ripper 未安装，部分功能受限"
    
    # 尝试各种方法
    log_info "开始破解过程..."
    
    # 1. 快速尝试
    if quick_try "$target_file" "$format"; then
        exit 0
    fi
    
    # 2. 字典攻击
    if dictionary_attack "$target_file" "$format" "$dict_file"; then
        exit 0
    fi
    
    # 3. 尝试高级字典
    if [ -f "advanced-passwords.txt" ]; then
        log_info "尝试高级字典..."
        if dictionary_attack "$target_file" "$format" "advanced-passwords.txt"; then
            exit 0
        fi
    fi
    
    # 4. 暴力破解（如果用户确认）
    read -p "是否尝试暴力破解？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "输入字符集 (1=数字, a=小写字母, A=大写字母, !=特殊字符): " charset
        read -p "最小长度: " min_len
        read -p "最大长度: " max_len
        
        brute_force "$target_file" "$format" "$charset" "$min_len" "$max_len"
    fi
    
    # 5. 使用 John the Ripper
    if command -v john &> /dev/null; then
        read -p "是否使用 John the Ripper？(y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            john_attack "$target_file" "$format"
        fi
    fi
    
    log_error "所有方法尝试完毕，未找到密码"
    exit 1
}

# 执行主函数
main "$@"