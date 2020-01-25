#!/usr/bin/env sh

##
# Yank text with w3m.
#
# @author qq542vev
# @version 1.1.1
# @date 2020-01-24
# @copyright Copyright (C) 2019-2020 qq542vev. Some rights reserved.
# @licence CC-BY <https://creativecommons.org/licenses/by/4.0/>
##

# 初期化
set -eu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# 各変数に既定値を代入する
yankFile=$(date "+${W3MPLUS_YANK_FILE}"; printf '$'); yankFile="${yankFile%?$}"
yankHeader=$(date "+${W3MPLUS_YANK_HEADER}"; printf '$'); yankHeader="${yankHeader%?$}"
yankFooter=$(date "+${W3MPLUS_YANK_FOOTER}"; printf '$'); yankFooter="${yankFooter%?$}"
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-f' | '--file')
			yankFile="${2}"
			shift 2
			;;
		'-F' | '--footer')
			yankFooter="${2}"
			shift 2
			;;
		'-H' | '--header')
			yankHeader="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0##*/} [OPTION]... [TEXT]...
				Yank text with w3m.

				 -f, --file=FILE      yank file
				 -F, --footer=STRING  footer text
				 -H, --header=STRING  header text
				 -h, --help           display this help and exit
				 -v, --version        output version information and exit
			EOF

			exit
			;;
		'-v' | '--version')
			cat <<- EOF
				${0##*/} (w3mplus) $(sed -n -e 's/^# @version //1p' -- "${0}") (Last update: $(sed -n -e 's/^# @date //1p' -- "${0}"))
				$(sed -n -e 's/^# @copyright //1p' -- "${0}")
				License: $(sed -n -e 's/^# @licence //1p' -- "${0}")
			EOF

			exit
			;;
		# 標準入力を処理する
		'-')
			arg=$( (cat; echo) | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '$');

			args="${args}${args:+ }'${arg%?$}'"
			shift
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

directory=$(dirname -- "${yankFile}"; printf '$')
mkdir -p -- "${directory%?$}"

# オプション以外の引数を再セットする
eval set -- "${args}"

if [ "${#}" -eq 0 ]; then
	set -- "$(cat)"
fi

context=$(for yankText in ${@+"${@}"}; do
	if [ -n "${yankHeader}" ]; then
		printf '%s' "${yankHeader}" | tee -a -- "${yankFile}"
	fi

	printf '%s' "${yankText}" | tee -a -- "${yankFile}"

	if [ -n "${yankFooter}" ]; then
		printf '%s' "${yankFooter}" | tee -a -- "${yankFile}"
	fi
done; printf '$')

output=$(printf '%s\n' "${context%$}" | sed -e "s/'\\{1,\\}/'\"&\"'/g; "'s/%/%%/g; s/\\/\\\\/g; s/\r/\\r/g; s/$/\\n/' | tr -d '\n')
number=$(printf '%s' "${context%$}" | grep -c -e '^')

httpResponseW3mBack.sh "W3m-control: EXEC_SHELL printf '${output}'; printf \"Add %d lines to '%s'\\n\" '${number}' '${yankFile}'"
