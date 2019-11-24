#!/usr/bin/env sh

##
# Move to the beginning of the line.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-07
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

# 各変数に既定値を代入する
endFlag='0'
line='1'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-e' | '--end')
			endFlag='1'

			shift
			;;
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
				Move to the beginning of the line.

				 -e, --end   move to end of line.
				 -l, --line  line number
				 -h, --help  display this help and exit
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

file="${1}"

# 引数の個数が過大である
if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

{
	printf 'W3m-control: GOTO_LINE %d\n' "${line}"

	if [ "${endFlag}" -eq 1 ]; then
		printf 'W3m-control: LINE_END\n'
		sed -n -e "${line}{s/^\\(.*[^ ]\\)\\{0,1\\}\\( *\\)\$/\\2/; s/ /W3m-control: MOVE_LEFT1\\n/gp; Q}" "${file}"
	else
		sed -n -e "${line}{s/^\\( *\\).*\$/\\1/; s/ /W3m-control: MOVE_RIGHT1\\n/gp; Q}" "${file}"
	fi
} | httpResponseW3mBack.sh -

rm -f "${file}"
