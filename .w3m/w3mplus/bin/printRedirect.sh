#!/usr/bin/env sh

## File: printRedirect.sh
##
## Print redirect message.
##
## Usage:
##
##   (start code)
##   printRedirect.sh [[OPTION]... [URI]]...
##   (end)
##
## Options:
##
## -H, --header-field=HEADER - HTTP header field after redirect
## -h, --help                - display this help and exit.
## -v, --version             - output version information and exit.
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
##   date - 2020-02-20
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
. "${W3MPLUS_PATH}/lib/w3mplus/functions"

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
			usage
			exit
			;;
		# バージョン情報を表示して終了する
		'-v' | '--version')
			version
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
