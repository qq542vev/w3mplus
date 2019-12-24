#!/usr/bin/env sh

##
# Restore w3m tabs.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-24
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

# 各変数に既定値を代入する
file="${W3MPLUS_PATH}/tabRestore"
count='1'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-f' | '--file')
			file="${2}"
			shift 2
			;;
		'-n' | '--number')
			if [ "$(expr "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			count="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]...
				Restore w3m tabs.

				 -f, --file    restore file
				 -n, --number  restore count
				 -h, --help    display this help and exit
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
				${0}: invalid option -- '${1}'
				Try '${0} --help' for more information.
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

directory=$(dirname "${file}"; printf '$')
mkdir -p "${directory%?$}"
: >>"${file}"

# オプション以外の引数を再セットする
eval set -- "${args}"

# 引数の個数が過大である
if [ 0 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

restoreData=$(cat "${file}")
date=$(($(date -u '+%Y%m%d%H%M%S' | utconv) - W3MPLUS_UNDO_TIMEOUT))
header=''

while [ -n "${restoreData}" ] && [ 1 -le "${count}" ]; do
	restore=$(printf '%s' "${restoreData}" | sed -n -e '$p')
	restoreUri=$(printf '%s' "${restore}" | cut -d ' ' -f 1)
	restoreDate=$(printf '%s' "${restore}" | cut -d ' ' -f 2 | tr -d 'TZ:-' | utconv)

	if [ "${date}" -lt "${restoreDate}" ]; then
		header=$(printf '%s\nW3m-control: TAB_GOTO %s\n' "${header}" "${restoreUri}")
		count=$((count - 1))
		restoreData=$(printf '%s' "${restoreData}" | sed -e '$d')
	else
		restoreData=''
	fi
done

printf '%s\n' "${restoreData}" | sed -e '/^$/d' >"${file}"

printf '%s\n' "${header}" | httpResponseW3mBack.sh -
