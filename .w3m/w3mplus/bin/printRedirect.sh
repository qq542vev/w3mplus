#!/usr/bin/env sh

##
# Print redirect message.
#
# @author qq542vev
# @version 1.0.0
# @date 2020-02-13
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

afterHeaderFields=''

headerFields=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-H' | '--header-field')
			afterHeaderFields="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0##*/} [OPTION]... [URL1] [OPTION]... [URL2]...
				Print redirect message.

				 -H, --header-field=HEADER  HTTP header field after redirect
				 -h, --help                 display this help and exit
				 -v, --version              output version information and exit
			EOF

			exit
			;;
		'-v' | '--version')
			cat <<- EOF
				${0##*/} (w3mplus) $(sed -n -e 's/^# @version //p' -- "${0}") (Last update: $(sed -n -e 's/^# @date //p' -- "${0}"))
				$(sed -n -e 's/^# @copyright //p' -- "${0}")
				License: $(sed -n -e 's/^# @licence //p' -- "${0}")
			EOF

			exit
			;;
		*)
			if [ "${W3MPLUS_REDIRECT_TYPE-0}" -eq 1 ]; then
				command='TAB_GOTO'
			else
				command='GOTO'
			fi

			if [ -z "${headerFields}" ]; then
				W3MPLUS_REDIRECT_TYPE='1'
			fi

			headerFields=$(printf '%s\nW3m-control: %s %s\n%s' "${headerFields}" "${command}" "${1}" "${afterHeaderFields}")
			shift
			;;
	esac
done

printf '%s\n' "${headerFields}" | httpResponseW3mBack.sh -
