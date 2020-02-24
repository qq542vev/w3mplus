#!/usr/bin/env sh

## File: contextMenu.sh
##
## Show w3m context menu.
##
## Usage:
##
##   (start code)
##   contextMenu.sh
##   (end)
##
## Options:
##
## Exit Status:
##
##   0 - Program terminated normally.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.1
##   date - 2020-02-19
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

# 初期化
set -efu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'


: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/init"

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
