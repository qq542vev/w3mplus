#!/usr/bin/env sh

##
# Call OperatorFunc.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-24
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

printText () (
	case "${LANG:-C}" in 'C')
		LANG='en_US.US-ASCII'
		;;
	esac

	charset="${LANG#*.}"

	cat | httpResponseNoCache.sh - "$(printf 'Content-Type: text/plain; charset=%s\n%s' "${charset}" "${1-}")"
)

# 各変数に既定値を代入する
number='$'
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
		'-n' | '--number')
			if [ "${2}" != '$' ] && [ "${2}" != '0' ] && [ "$(expr "${2}" ':' '[+-]\{0,1\}[1-9][0-9]*$')" -eq 0 ] && [ "$(expr "${2}" ':' '+-[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			number="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... FILE
				Call OperatorFunc.

				 -l, --line    line number
				 -n, --number  cut line
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
				args="${args}${args:+ }$(printf '%s' "${1}" | sed -e "s/./'&'/g; s/'''/\"'\"/g")"
				shift
			done
			;;
		# 複合ショートオプション
		'-'[!-][!-]*)
			option="${1}"
			shift
			# `-abc` を `-a -bc` に変換して再セットする
			set -- "-$(printf '%s' "${option}" | cut -c 2)" "-$(printf '%s' "${option}" | cut -c 3-)" ${@+"${@}"}
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
			args="${args}${args:+ }$(printf '%s' "${1}" | sed -e "s/./'&'/g; s/'''/\"'\"/g")"
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
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

if expr "${number}" ':' '[0+-]' >'/dev/null'; then
	if expr "${number}" ':' '+-' >'/dev/null'; then
		number="${number#+-}"
		line=$((line + number))
		number="$((number * -2))"
	fi

	number=$((line + number))

	if [ "${number}" -lt 1 ]; then
		number='1'
	fi
fi

if [ "${number}" = '$' ] || [ "${line}" -le "${number}" ]; then
	startLine="${line}"
	endLine="${number}"
else
	startLine="${number}"
	endLine="${line}"
fi

case "${action}" in
	'operatorFunc')
		tmpFile=$(mktemp)

		sed -e "${startLine},${endLine}!d" "${file}" >"${tmpFile}"

		printf "W3m-control: EXEC_SHELL cat '%s' | %s; rm -f '%s'\\n" "${tmpFile}" "${W3MPLUS_OPERATORFUNC}" "${tmpFile}" | httpResponseW3mBack.sh -
		;;
	'formatPrg')
		n=$((startLine - 1))

		{
			if [ 1 -le "${n}" ]; then
				sed -e "1,${n}!d" "${file}"
			fi

			sed -e "${startLine},${endLine}!d" "${file}" | ${W3MPLUS_FORMATPRG}
			sed -e "$((endLine + 1)),\$!d" "${file}"
		} | printText "W3m-control: GOTO_LINE ${startLine}"
		;;
	'filter')
		sed -e "${startLine},${endLine}!d" "${file}" | printText 'W3m-control: PIPE_BUF'
		;;
	'uppercase')
		sed -e "${startLine},${endLine}y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/" "${file}" | printText "W3m-control: GOTO_LINE ${startLine}"
		;;
	'lowercase')
		sed -e "${startLine},${endLine}y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/" "${file}" | printText "W3m-control: GOTO_LINE ${startLine}"
		;;
	'switchcase')
		sed -e "${startLine},${endLine}y/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/" "${file}" | printText "W3m-control: GOTO_LINE ${startLine}"
		;;
	'rot13')
		sed -e "${startLine},${endLine}y/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm/" "${file}"| printText "W3m-control: GOTO_LINE ${startLine}"

	;;
	'yank')
		sed -e "${startLine},${endLine}!d" | yank.sh
	;;
esac

rm -f "${file}"