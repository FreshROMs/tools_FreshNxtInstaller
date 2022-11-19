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
#  The Fresh Project
#  Copyright (C) 2019-2022 TenSeventy7
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

# Toolchain options
BUILD_PREF_COMPILER='gcc'
BUILD_PREF_COMPILER_VERSION='linaro'

# Local toolchain directory
TOOLCHAIN=$HOME/Android/toolchains/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu

# External toolchain directory
TOOLCHAIN_EXT=$(pwd)/toolchain

script_echo() {
	echo "  $1"
}

exit_script() {
	kill -INT $$
}

verify_toolchain() {
	sleep 2
	script_echo " "

	if [[ -d "${TOOLCHAIN}" ]]; then
		script_echo "I: Toolchain found at default location"
		export PATH="${TOOLCHAIN}/bin:$PATH"
		export LD_LIBRARY_PATH="${TOOLCHAIN}/lib:$LD_LIBRARY_PATH"
	else
		script_echo "I: Toolchain not found"
		script_echo "   Exiting..."
		kill -INT $$
	fi

	export CROSS_COMPILE=aarch64-linux-gnu-
	export CC=${BUILD_PREF_COMPILER}
}

verify_toolchain
make clean
make
