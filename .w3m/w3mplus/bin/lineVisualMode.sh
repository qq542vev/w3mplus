#!/usr/bin/env sh

##
# Start visual mode.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-24
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

# 各変数に既定値を代入する
line='1'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-l' | '--line')
			if [ "$(expr "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			line="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... FILE
				Start visual mode.

				 -l, --line    line number
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
				arg=$(printf '%s\n' "${1}" | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '_');

				args="${args}${args:+ }'${arg%?_}'"
				shift
			done
			;;
		# 複合ショートオプション
		'-'[!-][!-]*)
			option=$(printf '%s' "${1}" | cut -c '2'; printf '_')
			options=$(printf '%s' "${1}" | cut -c '3-'; printf '_')

			shift
			# `-abc` を `-a -bc` に変換して再セットする
			set -- "-${option%_}" "-${options%_}" ${@+"${@}"}
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
			arg=$(printf '%s\n' "${1}" | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '_');

			args="${args}${args:+ }'${arg%?_}'"
			shift
			;;
	esac
done

# オプション以外の引数を再セットする
eval set -- "${args}"

file="${1}"
checksum=$(cksum "${file}" | cut -d ' ' -f '1-2' | tr ' ' '-')

# 引数の個数が過大である
if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

: ${W3MPLUS_VISUALSTART:='  0'}

startChecksum=$(printf '%s' "${W3MPLUS_VISUALSTART}" | cut -d ' ' -f 1)
startLine=$(printf '%s' "${W3MPLUS_VISUALSTART}" | cut -d ' ' -f 2)
startTime=$(printf '%s' "${W3MPLUS_VISUALSTART}" | cut -d ' ' -f 3 | tr -d 'TZ:-' | utconv)

if [ "${checksum}" = "${startChecksum}" ] && [ "$(date -u '+%Y%m%d%H%M%S' | utconv)" -lt "$((startTime + W3MPLUS_VISUAL_TIMEOUT))" ]; then
	selectLine.sh -l "${startLine}" -n "${line}" 'yank' "${file}"
	printf 'W3m-control: SETENV W3MPLUS_VISUALSTART=\r\n'
else
	cat <<- EOF | httpResponseW3mBack.sh -
		W3m-control: SETENV W3MPLUS_VISUALSTART=${checksum} ${line} $(date -u '+%Y-%m-%dT%H:%M:%SZ')
		W3m-control: EXEC_SHELL printf 'Start visual mode from line %d\\n' '${line}'
	EOF
fi

rm -f "${file}"
