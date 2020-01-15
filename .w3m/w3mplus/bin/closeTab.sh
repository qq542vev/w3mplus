#!/usr/bin/env sh

##
# Close the tab and record the URI.
#
# @author qq542vev
# @version 1.1.0
# @date 2020-01-15
# @copyright Copyright (C) 2019-2020 qq542vev. Some rights reserved.
# @licence CC-BY <https://creativecommons.org/licenses/by/4.0/>
##

# 初期化
set -eu
umask 0022
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# 各変数に既定値を代入する
config="${W3MPLUS_PATH}/tabRestore"
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--config')
			config="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0##*/} [OPTION]... URI
				Close the tab and record the URI.

				 -c, --config=FILE  restore file
				 -h, --help         display this help and exit
			EOF

			exit
			;;
		'-v' | '--version')
			cat <<- EOF
				${0##*/} (w3mplus) $(sed -n -e 's/^# @version //1p' "${0}") (Last update: $(sed -n -e 's/^# @date //1p' "${0}"))
				$(sed -n -e 's/^# @copyright //1p' "${0}")
				License: $(sed -n -e 's/^# @licence //1p' "${0}")
			EOF

			exit
			;;
		# `--name=value` 形式のロングオプション
		'--'[!-]*'='*)
			option="${1}"
			shift
			# `--name value` に変換して再セットする
			set -- "${option%%=*}" "${option#*=}" ${@+"${@}"}
			;;
		# 以降はオプション以外の引数
		'--')
			shift

			while [ 1 -le "${#}" ]; do
				arg=$(printf '%s\n' "${1}" | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '$');

				args="${args}${args:+ }'${arg%?$}'"
				shift
			done
			;;
		# 複合ショートオプション
		'-'[!-][!-]*)
			option=$(printf '%s\n' "${1}" | cut -c '2'; printf '$')
			options=$(printf '%s\n' "${1}" | cut -c '3-'; printf '$')

			shift
			# `-abc` を `-a -bc` に変換して再セットする
			set -- "-${option%?$}" "-${options%?$}" ${@+"${@}"}
			;;
		# その他の無効なオプション
		'-'*)
			cat <<- EOF 1>&2
				${0##*/}: invalid option -- '${1}'
				Try '${0##*/} --help' for more information.
			EOF

			exit 64 # EX_USAGE </usr/include/sysexits.h>
			;;
		# その他のオプション以外の引数
		*)
			arg=$(printf '%s\n' "${1}" | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '$');

			args="${args}${args:+ }'${arg%?$}'"
			shift
			;;
	esac
done

directory=$(dirname "${config}"; printf '$')
mkdir -p "${directory%?$}"
: >>"${config}"

# オプション以外の引数を再セットする
eval set -- "${args}"

uri="${1}"

# 引数の個数が過大である
if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0##*/}: too many arguments
		Try '${0##*/} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

if [ -n "${uri}" ]; then
	if [ "${uri}" = "$(tail -n 1 "${config}" | cut -d ' ' -f 1)" ]; then (
		tmp=$(cat "${config}")
		printf '%s\n' "${tmp}" | sed -e '/^$/d; $d' >"${config}"
	) fi

	printf '%s %s\n' "${uri}" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >>"${config}"
fi

printf 'W3m-control: CLOSE_TAB' | httpResponseW3mBack.sh -
