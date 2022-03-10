#!/bin/bash
# =========================================
#         _____              _      
#        |  ___| __ ___  ___| |__   
#        | |_ | '__/ _ \/ __| '_ \  
#        |  _|| | |  __/\__ \ | | | 
#        |_|  |_|  \___||___/_| |_| 
#                              
# =========================================
#  
#  Minty - The kernel build script for Mint
#  The Fresh Project
#  Copyright (C) 2019-2021 TenSeventy7
#  
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.
#  
#  =========================
#

# Utility directories
ORIGIN_DIR=$(pwd)
CURRENT_BUILD_USER=$(whoami)
FRSH_DIR=/home/tenseventy7/Git/AROMA-Installer

MAJOR=12
MINOR=0
PATCH=1
CODENAME="Viola Alpha"

# Set build user if building locally
if [[ ${CURRENT_BUILD_USER} == "tenseventy7" ]]; then
	export KBUILD_BUILD_USER=TenSeventy7
	export KBUILD_BUILD_HOST=Lumiose-Build
fi

# Toolchain options
BUILD_PREF_COMPILER='gcc'
BUILD_PREF_COMPILER_VERSION='linaro'

# Local toolchain directory
TOOLCHAIN=$HOME/toolchains/linaro_last

# External toolchain directory
TOOLCHAIN_EXT=$(pwd)/toolchain

script_echo() {
	echo "  $1"
}

exit_script() {
	kill -INT $$
}

download_toolchain() {
	git clone https://github.com/TenSeventy7/exynos9610_toolchains_fresh.git ${TOOLCHAIN_EXT} --single-branch -b ${BUILD_PREF_COMPILER_VERSION} --depth 1 2>&1 | sed 's/^/     /'
	verify_toolchain
}

verify_toolchain() {
	sleep 2
	script_echo " "

	if [[ -d "${TOOLCHAIN}" ]]; then
		script_echo "I: Toolchain found at default location"
		export PATH="${TOOLCHAIN}/bin:$PATH"
		export LD_LIBRARY_PATH="${TOOLCHAIN}/lib:$LD_LIBRARY_PATH"
	elif [[ -d "${TOOLCHAIN_EXT}" ]]; then

		script_echo "I: Toolchain found at repository root"

		cd ${TOOLCHAIN_EXT}
		git pull
		cd ${ORIGIN_DIR}

		export PATH="${TOOLCHAIN_EXT}/bin:$PATH"
		export LD_LIBRARY_PATH="${TOOLCHAIN_EXT}/lib:$LD_LIBRARY_PATH"
	else
		script_echo "I: Toolchain not found at default location or repository root"
		script_echo "   Downloading recommended toolchain at ${TOOLCHAIN_EXT}..."
		download_toolchain
	fi

	export CROSS_COMPILE=aarch64-linux-gnu-
	export CC=${BUILD_PREF_COMPILER}
}

get_version() {
	# Get Fresh version and build date
	BUILD_DATE=$(date +"%a %b %d %H:%M:%S %:::z %Y")
	BUILD_VERSION_DATE=$(date +"%y%m%d")

	if [ -f "bin/build_date" -a -f "bin/build_version" -a -f "bin/build_version_full" ]; then
		LAST_DATE=$(cat "bin/build_date")
		if [ ${LAST_DATE} == ${BUILD_VERSION_DATE} ]; then
			BUILD_VER=$(cat "bin/build_version")

			if [[ ${#BUILD_VER} < 2 ]] 
			then
			    BUILD_VER="00${BUILD_VER}"
			    BUILD_VER="${BUILD_VER: -2}"
			fi

			BUILD_VERSION_FULL="${LAST_DATE}${BUILD_VER}"
			if [ ${BUILD_VERSION_FULL} == $(cat "bin/build_version_full") ]; then
				BUILD_VER=$(expr ${BUILD_VER} + '1')
				if [[ ${#BUILD_VER} < 2 ]] 
				then
				    BUILD_VER="00${BUILD_VER}"
				    BUILD_VER="${BUILD_VER: -2}"
				fi

				BUILD_VERSION_FULL="${LAST_DATE}${BUILD_VER}"
				echo "${BUILD_VER}" > "bin/build_version"
				echo "${BUILD_VERSION_FULL}" > "bin/build_version_full"
			fi
		else
			BUILD_VER="01"
			echo $(date +"%y%m%d") > "bin/build_date"
			echo "01" > "bin/build_version"
			BUILD_VERSION_FULL="${BUILD_VERSION_DATE}${BUILD_VER}"
			echo "${BUILD_VERSION_FULL}" > "bin/build_version_full"
		fi
	else
			BUILD_VER="01"
			echo $(date +"%y%m%d") > "bin/build_date"
			echo "01" > "bin/build_version"
			BUILD_VERSION_FULL="${BUILD_VERSION_DATE}${BUILD_VER}"
			echo "${BUILD_VERSION_FULL}" > "bin/build_version_full"
	fi
}

verify_toolchain
get_version
make clean
make AROMA_BUILD=${BUILD_VERSION_FULL} AROMA_VERSION="${MAJOR}.${MINOR}.${PATCH}.${BUILD_VER}" AROMA_CN="${CODENAME}"
