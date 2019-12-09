#!/usr/bin/env sh

##
# Yank text with w3m.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-08
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

# 各変数に既定値を代入する
yankFile=$(date "+${W3MPLUS_YANK_FILE}"; printf '_')
yankFile="${yankFile%?_}"
yankHeader=$(date "+${W3MPLUS_YANK_HEADER}"; printf '_')
yankHeader="${yankHeader%?_}"
yankFooter=$(date "+${W3MPLUS_YANK_FOOTER}"; printf '_')
yankFooter="${yankFooter%?_}"
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
				Usage: ${0} [OPTION] TEXT [TEXT]
				Yank text with w3m.

				 -f, --file    yank file
				 -F, --footer  footer text
				 -H, --header  header text
				 -h, --help    display this help and exit
			EOF

			exit
			;;
		# 標準入力を処理する
		'-')
			arg=$(sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '_');

			args="${args}${args:+ }'${arg%_}'"
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

directory=$(dirname "${yankFile}"; printf '_')
mkdir -p "${directory%?_}"

# オプション以外の引数を再セットする
eval set -- "${args}"

if [ "${#}" -eq 0 ]; then
	set -- "$(cat)"
fi

context=$(for yankText in ${@+"${@}"}; do
	if [ -n "${yankHeader}" ]; then
		printf '%s' "${yankHeader}" | tee -a "${yankFile}"
	fi

	printf '%s' "${yankText}" | tee -a "${yankFile}"

	if [ -n "${yankFooter}" ]; then
		printf '%s' "${yankFooter}" | tee -a "${yankFile}"
	fi
done; printf '_')

output=$(printf '%s\n' "${context%_}" | sed -e "s/'\\{1,\\}/'\"&\"'/g; "'s/%/%%/g; s/\\/\\\\/g; s/\r/\\r/g; s/$/\\n/' | tr -d '\n')
number=$(printf '%s' "${context%_}" | grep -c -e '^')

httpResponseW3mBack.sh "W3m-control: EXEC_SHELL printf '${output}'; printf \"Add %d lines to '%s'\\n\" '${number}' '${yankFile}'"
