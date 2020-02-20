#!/usr/bin/env sh

## File: selectLine.sh
##
## Performs an action on the selected row.
##
## Usage:
##
##   (start code)
##   selectLine.sh [OPTION]... ACTION FILE
##   (end)
##
## Options:
##
##   -l, --line=NUMBER   - line number
##   -n, --number=NUMBER - cut line
##   -h, --help          - display this help and exit
##   -v, --version       - output version information and exit
##
## Exit Status:
##
##   0  - Program terminated normally.
##   1< - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.1.4
##   date - 2020-02-20
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

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

# 各変数に既定値を代入する
line='1'
number='$'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-l' | '--line')
			if [ "$(expr -- "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			line="${2}"
			shift 2
			;;
		'-n' | '--number')
			if [ "${2}" != '$' ] && [ "${2}" != '0' ] && [ "$(expr -- "${2}" ':' '[+-]\{0,1\}[1-9][0-9]*$')" -eq 0 ] && [ "$(expr -- "${2}" ':' '+-[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			number="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			usage
			exit
			;;
		'-v' | '--version')
			version
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

# オプション以外の引数を再セットする
eval set -- "${args}"

action="${1}"
file="${2}"

# 引数の個数が過大である
if [ 2 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0##*/}: too many arguments
		Try '${0##*/} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

lineCount=$(grep -c -e '^' -- "${file}")

case "${number}" in
	'$')
		number="${lineCount}"
		;;
	'0' | [+-]*)
			case "${number}" in '+-'*)
				number="${number#+-}"
				line=$((line + number))
				number="$((number * -2))"
				;;
			esac

			number=$((line + number))

			if [ "${number}" -lt 1 ]; then
				number='1'
			fi
		;;
esac

if [ "${line}" -le "${number}" ]; then
	startLine="${line}"
	endLine="${number}"
else
	startLine="${number}"
	endLine="${line}"
fi

case "${action}" in
	'operatorFunc')
		tmpFile=$(mktemp)

		sed -e "${startLine},${endLine}!d" -- "${file}" >"${tmpFile}"

		printf "W3m-control: EXEC_SHELL cat -- '%s' | %s; rm -f -- '%s'\\n" "${tmpFile}" "${W3MPLUS_OPERATORFUNC}" "${tmpFile}" | httpResponseW3mBack.sh -
		;;
	'formatPrg')
		command=$(
			printf 'file=%%s;'

			if [ 2 -le "${startLine}" ]; then
				printf "sed -e '%s' -- \"\${file}\";" "$((startLine - 1))q"
			fi

			printf "sed -e '%s' -- \"\${file}\" | %s;" "${startLine},${endLine}!d" "${W3MPLUS_FORMATPRG}"
			printf "sed -e '%s' -- \"\${file}\";" "$((endLine + 1)),\$!d"
		)

		httpResponseW3mBack.sh - <<-EOF
			W3m-control: PIPE_BUF ${command}
			W3m-control: GOTO_LINE ${startLine}
		EOF
		;;
	'filter')
		if [ "${startLine}" -eq 1 ] && [ "${lineCount}" -le "${endLine}" ]; then
			httpResponseW3mBack.sh 'W3m-control: PIPE_BUF'
		else
			tmpFile=$(mktemp)
			cp -f -- "${file}" "${tmpFile}"

			commands=$(
				if [ 2 -le "${startLine}" ]; then
					printf "sed -e '%s' -- '%s';" "$((startLine - 1))q" "${tmpFile}"
				fi

				printf "cat -- %%s;"
				printf "sed -e '%s' '%s';" "$((endLine + 1)),\$!d" "${tmpFile}"
				printf "rm -f -- '%s';" "${tmpFile}"
			)

			httpResponseW3mBack.sh - <<- EOF
				W3m-control: PIPE_BUF	sed -e "${startLine},${endLine}!d" -- %s
				W3m-control: PIPE_BUF
				W3m-control: PIPE_BUF ${commands}
				W3m-control: DELETE_PREVBUF
				W3m-control: GOTO_LINE ${startLine}
			EOF
		fi
		;;
	'uppercase')
		httpResponseW3mBack.sh - <<- EOF
			W3m-control: PIPE_BUF sed -e "${startLine},${endLine}y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/" -- %s
			W3m-control: GOTO_LINE ${startLine}
		EOF
		;;
	'lowercase')
		httpResponseW3mBack.sh - <<- EOF
			W3m-control: PIPE_BUF sed -e "${startLine},${endLine}y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/" -- %s
			W3m-control: GOTO_LINE ${startLine}
		EOF
		;;
	'switchcase')
		httpResponseW3mBack.sh - <<- EOF
			W3m-control: PIPE_BUF sed -e '${startLine},${endLine}y/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/' -- %s
			W3m-control: GOTO_LINE ${startLine}
		EOF
		;;
	'rot13')
		httpResponseW3mBack.sh - <<- EOF
			W3m-control: PIPE_BUF sed -e '${startLine},${endLine}y/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm/' -- %s
			W3m-control: GOTO_LINE ${startLine}
		EOF
	;;
	'yank')
		sed -e "${startLine},${endLine}!d" -- "${file}" | yank.sh
	;;
esac
