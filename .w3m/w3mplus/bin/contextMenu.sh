#!/usr/bin/env sh

##
# Show w3m context menu.
#
# @author qq542vev
# @version 1.0.1
# @date 2020-01-27
# @copyright Copyright (C) 2019-2020 qq542vev. Some rights reserved.
# @licence CC-BY <https://creativecommons.org/licenses/by/4.0/>
##

# 初期化
set -eu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# 終了時の動作を設定する
trap 'exit 129' 1 # SIGHUP
trap 'exit 130' 2 # SIGINT
trap 'exit 131' 3 # SIGQUIT
trap 'exit 143' 15 # SIGTERM

if [ -n "${W3M_CURRENT_LINK-}" ] && [ -n "${W3M_CURRENT_IMG-}" ]; then
	menu='ContextMenuLinkImage'
elif [ -n "${W3M_CURRENT_LINK-}" ]; then
	menu='ContextMenuLink'
elif [ -n "${W3M_CURRENT_IMG-}" ]; then
	menu='ContextMenuImage'
else
	menu='Main'
fi

httpResponseW3mBack.sh "W3m-control: MENU ${menu}"
