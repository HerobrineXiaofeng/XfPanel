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
RED='\033[0;31m'

if [ "$(uname -s)" = "Darwin" ]; then
    echo "Current system is macOS. XFPanel cannot be installed here. Please use a Linux server (Debian/Ubuntu/CentOS) to install XFPanel."
    echo "Alternatively, install XFPanel via Docker."
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
    echo "Unsupported system architecture. Please use a supported OS/architecture listed in the official documentation."
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script as root${NC}"
  exit 1
fi

if [[ ! ${INSTALL_MODE} ]]; then
    INSTALL_MODE="stable"
else
    if [[ ${INSTALL_MODE} != "dev" && ${INSTALL_MODE} != "stable" ]]; then
        echo "Invalid INSTALL_MODE: ${INSTALL_MODE}. Supported values are: dev, stable."
        exit 1
    fi
fi

VERSION=$(curl -s https://dl.xfpanel.com/xfpanel/package/v1/${INSTALL_MODE}/latest)

if [[ -z ${VERSION} ]]; then
    echo "Failed to fetch the latest version (mode: ${INSTALL_MODE}). Please try again later."
    exit 1
fi

PACKAGE_FILE_NAME="xfpanel-${VERSION}-linux-${architecture}.tar.gz"

NODES=("https://dl.xfyr.cn" "https://dl.xfpanel.com" "https://mirrors.xfyr.cn")
PING_TIMEOUT=3
best="";min_t=9999.0

for n in "${NODES[@]}";do
  res=$(curl -s -o/dev/null -w "%{time_connect} %{http_code}" --connect-timeout $PING_TIMEOUT --max-time $PING_TIMEOUT "$n" 2>/dev/null)
  (( $? != 0 )) && continue
  read -r t c <<< "$res"
  (( c < 200 || c >= 300 )) && continue
  (( $(echo "$t < $min_t" | bc -l) )) && { min_t=$t; best=$n; }
done

[ -z "$best" ] && echo "All nodes cannot be downloaded." && exit 1
Note="$best"

HASH_FILE_URL="${Note}/xfpanel/package/v1/${INSTALL_MODE}/${VERSION}/release/checksums.txt"
EXPECTED_HASH=$(curl -s "$HASH_FILE_URL" | grep "$PACKAGE_FILE_NAME" | awk '{print $1}')

if [[ -f ${PACKAGE_FILE_NAME} ]]; then
    actual_hash=$(sha256sum "$PACKAGE_FILE_NAME" | awk '{print $1}')
    if [[ "$EXPECTED_HASH" == "$actual_hash" ]]; then
        echo "Local package found and checksum verified. Skipping download."
        rm -rf xfpanel-${VERSION}-linux-${architecture}
        tar zxf ${PACKAGE_FILE_NAME}
        cd xfpanel-${VERSION}-linux-${architecture}
        echo "$PANEL_EDITION" > "$EDITION_FILE"
        /bin/bash install.sh
        exit 0
    else
        echo "Local package checksum mismatch. Redownloading package."
        rm -f ${PACKAGE_FILE_NAME}
    fi
fi

PACKAGE_DOWNLOAD_URL="${Note}/xfpanel/package/v1/${INSTALL_MODE}/${VERSION}/release/${PACKAGE_FILE_NAME}"

echo "Preparing to download XfPanel ${VERSION} (${architecture}, mode: ${INSTALL_MODE})."
echo "Download URL: ${PACKAGE_DOWNLOAD_URL}"
curl -LOk ${PACKAGE_DOWNLOAD_URL}

if [[ ! -f ${PACKAGE_FILE_NAME} ]]; then
    echo "Package download failed. Please check network connectivity and retry."
    exit 1
fi

tar zxf ${PACKAGE_FILE_NAME}
if [[ $? != 0 ]]; then
    echo "Package extraction failed. The downloaded file may be incomplete or corrupted."
    rm -f ${PACKAGE_FILE_NAME}
    exit 1
fi
cd xfpanel-${VERSION}-linux-${architecture}

/bin/bash install.sh
