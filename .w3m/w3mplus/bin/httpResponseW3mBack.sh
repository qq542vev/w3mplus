#!/usr/bin/env sh

## File: httpResponseW3mBack.sh
##
## Displays a w3m back.
##
## Usage:
##
##   (start code)
##   httpResponseW3mBack.sh [HEADER_FIELD | FIELD_NAME FIELD_VALUE]...
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
##   version - 1.1.2
##   date - 2020-03-05
##   since - 2019-07-15
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

# initファイルの読み込み
: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/init"

headerFields=$(
	{
		case "${W3MPLUS_BACK-1}" in '1')
			printf 'W3m-control: BACK\n'
			;;
		esac

		while [ '1' -le "${#}" ]; do
			case "${1}" in
				'-')
					printf '%s\n' "$(cat)"
					shift
					;;
				*:*)
					printf '%s\n' "${1}"
					shift
					;;
				*)
					printf '%s: %s\n' "${1}: ${2}"
					shift
					;;
			esac
		done
	} | sed -e "/^$(printf '\r')*\$/d" | normalizehttpmsg --uncombined 'W3m-control' --unstructured 'W3m-control'

	printf '$'
)

"${W3MPLUS_TEMPLATE_HTTP}" -h "${headerFields%$}"
