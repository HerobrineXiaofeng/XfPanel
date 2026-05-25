#!/bin/bash
#
#       XfPanel Installer Script v1.0.0
#   GitHub: https://github.com/XfPanel/XfPanel
#   Author: HerobrineXiaofeng
#
#   This script installs XfPanel to your system.
#   Usage:
#
#   	bash <(curl -fsSL https://dl.xfpanel.com)
#   	or
#   	bash <(wget -qO- https://dl.xfpanel.com)
#
# ===================== 变量 =====================
GREEN='\033[0;32m'
C='\033[1;36m'
W='\033[1;37m'
RED='\033[0;31m'
CBL='\033[38;2;88;166;255m'
NC='\033[0m'
CHANNEL="stable"
PANEL_DIR="/www/xfpanel"
CONF_DIR="${PANEL_DIR}/config"
LANG_FILE="${CONF_DIR}/lang.json"

if [ "$(uname -s)" = "Darwin" ]; then
    echo "错误：当前系统为 macOS，暂不支持安装！"
    exit 1
fi

# 系统架构检测
osCheck=$(uname -a)
if [[ $osCheck =~ 'x86_64' ]]; then
    architecture="amd64"
elif [[ $osCheck =~ 'arm64' ]] || [[ $osCheck =~ 'aarch64' ]]; then
    architecture="arm64"
#elif [[ $osCheck =~ 'armv7l' ]]; then
#    architecture="armv7"
#elif [[ $osCheck =~ 'ppc64le' ]]; then
#    architecture="ppc64le"
#elif [[ $osCheck =~ 's390x' ]]; then
#    architecture="s390x"
#elif [[ $osCheck =~ 'riscv64' ]]; then
#    architecture="riscv64"
else
    echo "当前系统架构暂不支持，请参考官方文档选择受支持的系统与架构。"
    exit 1
fi

# 必须 root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}请以 root 用户身份运行此脚本 / 請以 root 用戶身份運行此腳本 / Please run this script as root${NC}"
  exit 1
fi

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --stable)
                CHANNEL="stable"
                shift
                ;;
            --dev)
                CHANNEL="dev"
                shift
                ;;
            *)
                echo -e "${CBL}未知参数: $1${NC}"
                exit 1
                ;;
        esac
    done
}

# 修复：逻辑顺序 先解析参数
parse_args "$@"

VERSION=$(curl -s https://dl.xfpanel.com/xfpanel/package/v1/${CHANNEL_URL}/latest)

echo -e "${CBL}XfPanel for ${VERSION} Linux Distribution${NC}"
read -p "是否继续安装？/ 是否繼續安裝？/ Continue installation? (Y/N): " confirm
case $confirm in
    Y|y) ;;
    N|n)
        echo -e "${RED}已取消安装，如需重新安装请运行下面安装命: / 已取消安裝，如需重新安裝請運行下面安裝命令: / Installation cancelled. To reinstall, please run the command below:${NC}"
        echo "bash <(curl -fsSL https://dl.xfpanel.com)"
        exit 0
        ;;
    *)
        echo -e "${RED}错误；请输入 Y 或 N / 錯誤；請輸入 Y 或 N / Error: Please enter Y or N only.${NC}"
        exit 1
        ;;
esac

# 安装jq依赖（解析JSON必备，有则跳过，无则安装并校验）
if command -v jq &>/dev/null; then
    echo -e "${CBL}检测到已安装 jq，跳过安装${NC}"
else
    echo -e "${CBL}未检测到 jq，开始自动安装依赖...${NC}"
    if command -v apt &>/dev/null; then
        # Debian / Ubuntu / Linux Mint
        apt update -y && apt install jq -y
    elif command -v dnf &>/dev/null; then
        # Fedora / CentOS 8+ / RHEL 8+
        dnf install jq -y
    elif command -v yum &>/dev/null; then
        # CentOS 7 / RHEL 7
        yum install jq -y
    elif command -v pacman &>/dev and/null; then
        # Arch Linux / Manjaro
        pacman -Syu --noconfirm jq
    elif command -v zypper &>/dev/null; then
        # openSUSE / SLES
        zypper install -y jq
    elif command -v apk &>/dev/null; then
        # Alpine Linux
        apk add --update jq
    else
        echo -e "${RED}错误：当前系统未适配的包管理器，请手动安装 jq 后重试${NC}"
        exit 1
    fi

    # 安装完成二次校验
    if ! command -v jq &>/dev/null; then
        echo -e "${RED}错误：jq 安装失败，请检查网络或系统仓库配置${NC}"
        exit 1
    else
        echo -e "${GREEN}jq 安装成功${NC}"
    fi
fi

# ==================== 多语言核心函数 ====================
first_lang_choose() {
    [ -d "${CONF_DIR}" ] || mkdir -p -m 700 "${CONF_DIR}"
    while true; do
        echo -e "${CBL}Select a language:${NC}"
        echo "1) 简体中文"
        echo "2) 繁體中文"
        echo "3) English"
        read -rp "Your choice: " sel < /dev/tty
        case "$sel" in
            1) echo '{"lang":"zh_cn"}' > "${LANG_FILE}" && break ;;
            2) echo '{"lang":"zh_hk"}' > "${LANG_FILE}" && break ;;
            3) echo '{"lang":"en"}'    > "${LANG_FILE}" && break ;;
            *) echo -e "${RED}Invalid input, please try again.${NC}" ;;
        esac
    done
    # 创建完立刻锁权限
    chmod 600 "${LANG_FILE}"
    chown root:root "${LANG_FILE}"
}

init_lang() {
    if [ ! -f "${LANG_FILE}" ]; then
        first_lang_choose
    fi
    # JSON 读取语言
    CURRENT_LANG=$(jq -r '.lang' "${LANG_FILE}" 2>/dev/null)
    # 解析失败兜底 zh_cn
    CURRENT_LANG=${CURRENT_LANG:-zh_cn}
    export CURRENT_LANG
}

lang_text() {
    local key="$1"
    case "${CURRENT_LANG}" in
        zh_cn)
            case "$key" in
                install_confirm) echo "是否继续安装 XfPanel？(y/N) " ;;
                installer_text) echo "安装程序" ;;
                channel_text) echo "渠道" ;;
                starttheinstallation_text) echo "开始安装" ;;
            esac
        ;;
        zh_hk)
            case "$key" in
                install_confirm) echo "是否繼續安裝 XfPanel？(y/N) " ;;
                installer_text) echo "安裝程序" ;;
                channel_text) echo "渠道" ;;
                starttheinstallation_text) echo "開始安裝" ;;
            esac
        ;;
        en)
            case "$key" in
                install_confirm) echo "Continue to install XfPanel? (y/N) " ;;
                installer_text) echo "Installer" ;;
                channel_text) echo "Channel" ;;
                starttheinstallation_text) echo "Starting installation" ;;
            esac
        ;;
    esac
}

init_lang

if [[ "x${VERSION}" == "x" ]]; then
    echo "获取最新版本失败（模式：${CHANNEL}），请稍后重试。"
    exit 1
fi

PACKAGE_FILE_NAME="xfpanel-${VERSION}-linux-${architecture}.tar.gz"
#PACKAGE_DOWNLOAD_URL="https://dlxfpanel.com/package/${SERIES}/${CHANNEL}/${VERSION}/${PACKAGE_FILE_NAME}"

clear
cat << EOF
██╗  ██╗███████╗██████╗  █████╗ ███╗   ██╗███████╗██╗     
╚██╗██╔╝██╔════╝██╔══██╗██╔══██╗████╗  ██║██╔════╝██║     
 ╚███╔╝ █████╗  ██████╔╝███████║██╔██╗ ██║█████╗  ██║     
 ██╔██╗ ██╔══╝  ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║     
██╔╝ ██╗██║     ██║     ██║  ██║██║ ╚████║███████╗███████╗
╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝
EOF
echo "         XfPanel $(lang_text installer_text) ${VERSION} ${CHANNEL} $(lang_text channel_text)         "
echo -e "${CBL}[XfPanel $(date +"%Y-%m-%d %H:%M:%S") install Log]: ======================= $(lang_text starttheinstallation_text) =======================${NC}"

REPO_OFFICIAL="https://dl.xfpanel.com/xfpanel/package/v1/${CHANNEL}/${VERSION}/${PACKAGE_FILE_NAME}"
REPO_OFFICIAL_CN="https://dl.xfyr.cn/xfpanel/package/v1/${CHANNEL}/${VERSION}/${PACKAGE_FILE_NAME}"

PING_TIMEOUT=3

check_source() {
    local url="$1"
    curl -s --connect-timeout ${PING_TIMEOUT} --max-time ${PING_TIMEOUT} "$url" >/dev/null 2>&1
    return $?
}

# 快速判断本机公网 IP 是否位于中国大陆（返回 0 表示中国，1 表示非中国或检测失败）
is_china_region() {
    local country_code
    # 使用 ip-api.com 的免费接口，只取 countryCode 字段，设置短超时
    country_code=$(curl -s --connect-timeout 2 --max-time 5 "http://ip-api.com/json/?fields=countryCode" \
        | grep -o '"countryCode":"[^"]*"' | cut -d'"' -f4 2>/dev/null)
    
    if [[ "$country_code" == "CN" ]]; then
        return 0   # 是中国
    else
        return 1   # 非中国或获取失败
    fi
}

# ========== 主逻辑：根据地区选择源顺序 ==========

if is_china_region; then
    if check_source "${REPO_OFFICIAL_CN}"; then
        PACKAGE_DOWNLOAD_URL="${REPO_OFFICIAL_CN}"
        INSTALLATION_SOURCE="Official CN Source"
    elif check_source "${REPO_OFFICIAL}"; then
        PACKAGE_DOWNLOAD_URL="${REPO_OFFICIAL}"
        INSTALLATION_SOURCE="Official Source"
    else
        echo "所有节点无法下载"
        exit 1
    fi
else
    if check_source "${REPO_OFFICIAL}"; then
        PACKAGE_DOWNLOAD_URL="${REPO_OFFICIAL}"
        INSTALLATION_SOURCE="Official Source"
    elif check_source "${REPO_OFFICIAL_CN}"; then
        PACKAGE_DOWNLOAD_URL="${REPO_OFFICIAL_CN}"
        INSTALLATION_SOURCE="Official CN Source"
    else
        echo "所有节点无法下载"
        exit 1
    fi
fi

echo -e "${CBL}[XfPanel $(date +"%Y-%m-%d %H:%M:%S") install Log]: 已自动匹配安装源: ${INSTALLATION_SOURCE}${NC}" 
echo -e "${CBL}[XfPanel $(date +"%Y-%m-%d %H:%M:%S") install Log]: 下载地址: ${PACKAGE_DOWNLOAD_URL}(暂未创建压缩包)${NC}"
echo -e "${CBL}[XfPanel $(date +"%Y-%m-%d %H:%M:%S") install Log]: 下载中...${NC}"
# 暂时无法下载(无文件)
#curl -LOk ${PACKAGE_DOWNLOAD_URL}
echo -e "${CBL}[XfPanel $(date +"%Y-%m-%d %H:%M:%S") install Log]: 下载文件完成，开始解压到${PANEL_DIR}(因为无文件，暂未有解压)${NC}"
#rm -rf ${PANEL_DIR}
#mkdir -p ${PANEL_DIR} #&& tar -zxvf ${PACKAGE_FILE_NAME} -C /www/xfpanel/
