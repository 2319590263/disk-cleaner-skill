#!/bin/bash
# 压缩包破解工具安装脚本
# 支持 Linux, macOS, Windows (WSL)

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 检测操作系统
detect_os() {
    case "$(uname -s)" in
        Linux*)
            if [ -f /etc/debian_version ]; then
                echo "debian"
            elif [ -f /etc/redhat-release ]; then
                echo "rhel"
            elif [ -f /etc/arch-release ]; then
                echo "arch"
            else
                echo "linux"
            fi
            ;;
        Darwin*)
            echo "macos"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# 检查包管理器
check_package_manager() {
    local os="$1"
    
    case "$os" in
        debian|ubuntu)
            if command -v apt-get &> /dev/null; then
                echo "apt"
            else
                echo "unknown"
            fi
            ;;
        rhel|centos|fedora)
            if command -v yum &> /dev/null; then
                echo "yum"
            elif command -v dnf &> /dev/null; then
                echo "dnf"
            else
                echo "unknown"
            fi
            ;;
        arch)
            if command -v pacman &> /dev/null; then
                echo "pacman"
            else
                echo "unknown"
            fi
            ;;
        macos)
            if command -v brew &> /dev/null; then
                echo "brew"
            else
                echo "unknown"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# 安装工具函数
install_tool() {
    local tool="$1"
    local os="$2"
    local pm="$3"
    
    log_info "安装 $tool..."
    
    case "$os" in
        debian|ubuntu)
            case "$pm" in
                apt)
                    sudo apt-get install -y "$tool"
                    ;;
                *)
                    log_error "不支持的包管理器"
                    return 1
                    ;;
            esac
            ;;
        rhel|centos)
            case "$pm" in
                yum)
                    sudo yum install -y "$tool"
                    ;;
                dnf)
                    sudo dnf install -y "$tool"
                    ;;
                *)
                    log_error "不支持的包管理器"
                    return 1
                    ;;
            esac
            ;;
        fedora)
            case "$pm" in
                dnf)
                    sudo dnf install -y "$tool"
                    ;;
                *)
                    log_error "不支持的包管理器"
                    return 1
                    ;;
            esac
            ;;
        arch)
            case "$pm" in
                pacman)
                    sudo pacman -S --noconfirm "$tool"
                    ;;
                *)
                    log_error "不支持的包管理器"
                    return 1
                    ;;
            esac
            ;;
        macos)
            case "$pm" in
                brew)
                    brew install "$tool"
                    ;;
                *)
                    log_error "请先安装 Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                    return 1
                    ;;
            esac
            ;;
        *)
            log_warning "未知操作系统，请手动安装 $tool"
            return 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        log_success "$tool 安装成功"
        return 0
    else
        log_error "$tool 安装失败"
        return 1
    fi
}

# 安装基本工具
install_basic_tools() {
    local os="$1"
    local pm="$2"
    
    log_info "安装基本压缩工具..."
    
    case "$os" in
        debian|ubuntu)
            install_tool "p7zip-full" "$os" "$pm"
            install_tool "unrar" "$os" "$pm"
            install_tool "zip" "$os" "$pm"
            install_tool "unzip" "$os" "$pm"
            ;;
        rhel|centos|fedora)
            install_tool "p7zip" "$os" "$pm"
            install_tool "unrar" "$os" "$pm"
            install_tool "zip" "$os" "$pm"
            install_tool "unzip" "$os" "$pm"
            ;;
        arch)
            install_tool "p7zip" "$os" "$pm"
            install_tool "unrar" "$os" "$pm"
            install_tool "zip" "$os" "$pm"
            install_tool "unzip" "$os" "$pm"
            ;;
        macos)
            install_tool "p7zip" "$os" "$pm"
            install_tool "unrar" "$os" "$pm"
            ;;
        *)
            log_warning "请手动安装压缩工具"
            ;;
    esac
}

# 安装破解工具
install_crack_tools() {
    local os="$1"
    local pm="$2"
    
    log_info "安装密码破解工具..."
    
    # fcrackzip
    case "$os" in
        debian|ubuntu)
            install_tool "fcrackzip" "$os" "$pm"
            ;;
        rhel|centos|fedora)
            # 可能需要从源码编译
            log_info "编译安装 fcrackzip..."
            sudo yum install -y gcc make zlib-devel || sudo dnf install -y gcc make zlib-devel
            wget https://github.com/hyc/fcrackzip/archive/refs/tags/1.0.tar.gz
            tar -xzf 1.0.tar.gz
            cd fcrackzip-1.0
            make
            sudo make install
            cd ..
            rm -rf 1.0.tar.gz fcrackzip-1.0
            ;;
        arch)
            install_tool "fcrackzip" "$os" "$pm"
            ;;
        macos)
            install_tool "fcrackzip" "$os" "$pm"
            ;;
        *)
            log_warning "请手动安装 fcrackzip"
            ;;
    esac
    
    # John the Ripper
    case "$os" in
        debian|ubuntu)
            install_tool "john" "$os" "$pm"
            ;;
        rhel|centos|fedora)
            install_tool "john" "$os" "$pm"
            ;;
        arch)
            install_tool "john" "$os" "$pm"
            ;;
        macos)
            install_tool "john-jumbo" "$os" "$pm"
            ;;
        *)
            log_warning "请手动安装 John the Ripper"
            ;;
    esac
    
    # Hashcat
    case "$os" in
        debian|ubuntu)
            install_tool "hashcat" "$os" "$pm"
            ;;
        rhel|centos|fedora)
            install_tool "hashcat" "$os" "$pm"
            ;;
        arch)
            install_tool "hashcat" "$os" "$pm"
            ;;
        macos)
            install_tool "hashcat" "$os" "$pm"
            ;;
        *)
            log_warning "请手动安装 Hashcat"
            ;;
    esac
}

# 安装辅助工具
install_helper_tools() {
    local os="$1"
    local pm="$2"
    
    log_info "安装辅助工具..."
    
    # Crunch (密码生成器)
    case "$os" in
        debian|ubuntu)
            install_tool "crunch" "$os" "$pm"
            ;;
        rhel|centos|fedora)
            install_tool "crunch" "$os" "$pm"
            ;;
        arch)
            install_tool "crunch" "$os" "$pm"
            ;;
        macos)
            brew install crunch
            ;;
        *)
            log_warning "请手动安装 Crunch"
            ;;
    esac
    
    # CeWL (网站字典生成器)
    case "$os" in
        debian|ubuntu)
            install_tool "cewl" "$os" "$pm"
            ;;
        rhel|centos|fedora)
            # 可能需要从源码安装
            log_info "安装 CeWL..."
            sudo yum install -y ruby || sudo dnf install -y ruby
            gem install cewl
            ;;
        arch)
            install_tool "cewl" "$os" "$pm"
            ;;
        macos)
            brew install cewl
            ;;
        *)
            log_warning "请手动安装 CeWL"
            ;;
    esac
    
    # Hydra (网络破解工具)
    case "$os" in
        debian|ubuntu)
            install_tool "hydra" "$os" "$pm"
            ;;
        rhel|centos|fedora)
            install_tool "hydra" "$os" "$pm"
            ;;
        arch)
            install_tool "hydra" "$os" "$pm"
            ;;
        macos)
            brew install hydra
            ;;
        *)
            log_warning "请手动安装 Hydra"
            ;;
    esac
}

# 安装 Python 依赖
install_python_deps() {
    log_info "安装 Python 依赖..."
    
    if command -v python3 &> /dev/null; then
        python3 -m pip install --upgrade pip
        python3 -m pip install requests beautifulsoup4 lxml
        log_success "Python 依赖安装成功"
    else
        log_warning "Python3 未安装，跳过依赖安装"
    fi
}

# 下载额外字典
download_wordlists() {
    log_info "下载密码字典..."
    
    # RockYou 字典 (如果不存在)
    if [ ! -f "rockyou.txt" ]; then
        log_info "下载 RockYou 字典..."
        wget -q https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
        if [ $? -eq 0 ]; then
            log_success "RockYou 字典下载成功"
        else
            log_warning "RockYou 字典下载失败"
        fi
    fi
    
    # 其他常用字典
    declare -A wordlists=(
        ["common-passwords.txt"]="https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt"
        ["xato-net-10-million.txt"]="https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/xato-net-10-million-passwords.txt"
    )
    
    for filename in "${!wordlists[@]}"; do
        if [ ! -f "$filename" ]; then
            log_info "下载 $filename..."
            wget -q -O "$filename" "${wordlists[$filename]}"
            if [ $? -eq 0 ]; then
                log_success "$filename 下载成功"
            else
                log_warning "$filename 下载失败"
            fi
        fi
    done
}

# 主安装函数
main_install() {
    log_info "开始安装压缩包破解工具集..."
    
    # 检测操作系统
    local os=$(detect_os)
    log_info "检测到操作系统: $os"
    
    # 检测包管理器
    local pm=$(check_package_manager "$os")
    if [ "$pm" = "unknown" ]; then
        log_error "无法检测包管理器，请手动安装工具"
        return 1
    fi
    log_info "使用包管理器: $pm"
    
    # 更新包管理器
    log_info "更新包管理器..."
    case "$os" in
        debian|ubuntu)
            sudo apt-get update
            ;;
        rhel|centos)
            sudo yum update -y || true
            ;;
        fedora)
            sudo dnf update -y || true
            ;;
        arch)
            sudo pacman -Sy
            ;;
        macos)
            brew update
            ;;
    esac
    
    # 安装工具
    install_basic_tools "$os" "$pm"
    install_crack_tools "$os" "$pm"
    install_helper_tools "$os" "$pm"
    install_python_deps
    download_wordlists
    
    log_success "所有工具安装完成！"
    log_info ""
    log_info "已安装工具:"
    log_info "  - 7-Zip / p7zip"
    log_info "  - fcrackzip"
    log_info "  - John the Ripper"
    log_info "  - Hashcat"
    log_info "  - Crunch"
    log_info "  - CeWL"
    log_info "  - Hydra"
    log_info ""
    log_info "使用示例:"
    log_info "  ./auto-crack.sh secret.zip"
    log_info "  python3 generate-wordlists.py custom-passwords.txt --type=all"
}

# 执行安装
if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    main_install
fi