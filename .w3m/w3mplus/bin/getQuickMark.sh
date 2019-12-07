#!/usr/bin/env sh

##
# Get a quick mark.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-24
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

# 各変数に既定値を代入する
markFile="${W3MPLUS_PATH}/quickmark"
gotoLine='0'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-f' | '--file')
			markFile="${2}"
			shift 2
			;;
		'-l' | '--line')
			gotoLine='1'
			shift
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION] KEY
				Get a quick mark.

				 -f, --file  quick mark file
				 -l, --line  jump to line
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

directory=$(dirname "${markFile}"; printf '_')
mkdir -p "${directory%?_}"
: >>"${markFile}"

# オプション以外の引数を再セットする
eval set -- "${args}"

if [ "${#}" -eq 0 ]; then
	set -- $(cat)
fi

goto=''
afterHeader=''

for key in ${@+"${@}"}; do
	key=$(printf '%s' "${key}" | sed -e 's/[].\*[]/\\&/g; 1s/^^/\\^/; $s/$$/\\$/')

	if mark=$(grep -m 1 -e "^${key} " "${markFile}"); then
		uri=$(printf '%s' "${mark}" | cut -d ' ' -f 2)
		line=$(printf '%s' "${mark}" | cut -d ' ' -f 3)

		if [ -z "${goto}" ]; then
			goto="${uri}"
		else
			afterHeader=$(printf '%s\nW3m-control: TAB_GOTO %s' "${afterHeader}" "${uri}")
		fi

		if [ "${gotoLine}" -eq 1 ]; then
			afterHeader=$(printf '%s\nW3m-control: GOTO_LINE %d' "${afterHeader}" "${line}")
		fi
	fi
done

if [ -z "${goto}" ]; then
	httpResponseW3mBack.sh
else
	printRedirect.sh "${goto}" "${afterHeader}"
fi
