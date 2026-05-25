#!/bin/bash
#
#       XfPanel Installer Script v1.0.0
#   GitHub: https://github.com/HerobrineXiaofeng/XfPanel
#   Author: HerobrineXiaofeng
#
#   This script installs XfPanel to your system.
#   Usage:
#
#   	bash <(curl -fsSL https://dl.xfpanel.com/xfpanel/package/v1/install.sh)
#   	or
#   	bash <(wget -qO- https://dl.xfpanel.com/xfpanel/package/v1/install.sh)
#
#   ------------------------------------------------------------------------
#   Copyright (C) 2026 HerobrineXiaofeng
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License v3.0.
#   See LICENSE file or <https://www.gnu.org/licenses/> for full terms.
#   -----------------------------------------------------------------------
#
if [ "$(uname -s)" = "Darwin" ]; then
    echo "错误：当前系统为 macOS，暂不支持安装！"
    exit 1
fi

architectureCheck=$(uname -a)
if [[ $architectureCheck =~ 'x86_64' ]]; then
    architecture="amd64"
elif [[ $architectureCheck =~ 'arm64' ]] || [[ $architectureCheck =~ 'aarch64' ]]; then
    architecture="arm64"
#elif [[ $architectureCheck =~ 'armv7l' ]]; then
#    architecture="armv7"
#elif [[ $architectureCheck =~ 'ppc64le' ]]; then
#    architecture="ppc64le"
#elif [[ $architectureCheck =~ 's390x' ]]; then
#    architecture="s390x"
#elif [[ $architectureCheck =~ 'riscv64' ]]; then
#    architecture="riscv64"
else
    echo "当前系统架构暂不支持，请参考官方文档选择受支持的系统与架构。"
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}请以 root 用户身份运行此脚本 / 請以 root 用戶身份運行此腳本 / Please run this script as root${NC}"
  exit 1
fi

INSTALL_CHANNEL="stable"
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --stable)
                INSTALL_CHANNEL="stable"
                shift
                ;;
            --dev)
                INSTALL_CHANNEL="dev"
                shift
                ;;
            *)
                echo -e "${CBL}未知参数: $1${NC}"
                exit 1
                ;;
        esac
    done
}

parse_args "$@"

VERSION=$(curl -s https://dl.xfpanel.com/xfpanel/package/v1/${INSTALL_CHANNEL}/latest)
#HASH_FILE_URL="https://resource.1panel.pro/v2/${INSTALL_CHANNEL}/${VERSION}/release/checksums.txt"

if [[ -z ${VERSION} ]]; then
    echo "Failed to fetch the latest version (mode: ${INSTALL_CHANNEL}). Please try again later."
    exit 1
fi

PACKAGE_FILE_NAME="xfpanel-${VERSION}-linux-${architecture}.tar.gz"
OFFICIAL_Global_Node="https://dl.xfpanel.com"
OFFICIAL_CN_Node="https://dl.xfyr.cn"

PING_TIMEOUT=3

check_source() {
    local url="$1"
    curl -s --connect-timeout ${PING_TIMEOUT} --max-time ${PING_TIMEOUT} "$url" >/dev/null 2>&1
    return $?
}

is_china_region() {
    local country_code
    country_code=$(curl -s --connect-timeout 2 --max-time 5 "http://ip-api.com/json/?fields=countryCode" \
        | grep -o '"countryCode":"[^"]*"' | cut -d'"' -f4 2>/dev/null)
    
    if [[ "$country_code" == "CN" ]]; then
        return 0
    else
        return 1
    fi
}

if is_china_region; then
    if check_source "${OFFICIAL_CN_Node}"; then
        Note="${OFFICIAL_CN_Node}"
    elif check_source "${OFFICIAL_Global_Node}"; then
        Note="${OFFICIAL_Global_Node}"
    else
        echo "All nodes cannot be downloaded."
        exit 1
    fi
else
    if check_source "${OFFICIAL_Global_Node}"; then
        Note="${OFFICIAL_Global_Node}"
    elif check_source "${OFFICIAL_CN_Node}"; then
        Note="${OFFICIAL_CN_Node}"
    else
        echo "All nodes cannot be downloaded."
        exit 1
    fi
fi

PACKAGE_DOWNLOAD_URL="${Note}/xfpanel/package/v1/${INSTALL_CHANNEL}/${VERSION}/release/${PACKAGE_FILE_NAME}"

echo "Preparing to download XfPanel ${VERSION} (${architecture}, mode: ${INSTALL_CHANNEL})."
echo "Download URL: ${PACKAGE_DOWNLOAD_URL}"
