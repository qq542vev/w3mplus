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
##   0  - Program terminated normally.
##   1< - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.1.1
##   date - 2020-02-20
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues

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

: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/functions"

headerFields='W3m-control: BACK'

while [ '1' -le "${#}" ]; do
	case "${1}" in
		'-')
			headerFields=$(printf '%s\n%s' "${headerFields}" "$(cat)")
			shift
			;;
		*:*)
			headerFields=$(printf '%s\n%s' "${headerFields}" "${1}")
			shift
			;;
		*)
			headerFields=$(printf '%s\n%s' "${headerFields}" "${1}: ${2}")
			shift
			;;
	esac
done

headerFields=$(printf '%s\n' "${headerFields}" | sed -e "/^$(printf '\r')*\$/d" | normalizeHttpMessage.sh --uncombined 'W3m-control'; printf '$')
headerFields="${headerFields%$}"

"${W3MPLUS_TEMPLATE_HTTP}" -h "${headerFields}"
