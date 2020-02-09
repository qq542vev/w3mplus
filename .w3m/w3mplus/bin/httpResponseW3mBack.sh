#!/usr/bin/env sh

##
# Displays a w3m back.
#
# @author qq542vev
# @version 1.1.0
# @date 2020-02-07
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

: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/config"

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

headerFields=$(printf '%s\n' "${headerFields}" | sed -e "/^$(printf '\r')*\$/d" | normalizeHttpMessage.sh -u 'W3m-control'; printf '$')
headerFields="${headerFields%$}"

"${W3MPLUS_TEMPLATE_HTTP}" -h "${headerFields}"
