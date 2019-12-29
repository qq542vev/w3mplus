#!/usr/bin/env sh

##
# Show w3m context menu.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-08
# @licence https://creativecommons.org/licenses/by/4.0/
##

# 初期化
set -eu
umask 0022
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

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
