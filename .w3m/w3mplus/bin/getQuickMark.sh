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

gotoMove () (
	line="${1}"
	colmun="${2}"

	if [ "${gotoLine}" -eq 1 ]; then
		if [ 0 -lt "${line}" ]; then
			printf 'W3m-control: GOTO_LINE %d\n' "${line}"
		else
			printf 'W3m-control: END\n'

			while [ "${line}" -lt 0 ]; do
				printf 'W3m-control: MOVE_UP1\n'
				line=$((line + 1))
			done
		fi
	fi

	if [ "${gotoColmun}" -eq 1 ]; then
		if [ 0 -lt "${colmun}" ]; then
			while [ 1 -lt "${colmun}"  ]; do
				printf 'W3m-control: MOVE_RIGHT1\n'
				colmun=$((colmun - 1))
			done
		else
			printf 'W3m-control: LINE_END\n'

			while [ "${colmun}" -lt 0 ]; do
				printf 'W3m-control: MOVE_LEFT1\n'
				colmun=$((colmun + 1))
			done
		fi
	fi
)

# 各変数に既定値を代入する
config="${W3MPLUS_PATH}/quickmark"
gotoColmun='0'
gotoLine='0'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--config')
			config="${2}"
			shift 2
			;;
		'-C' | '--colmun')
			gotoColmun='1'
			shift
			;;
		'-l' | '--line')
			gotoLine='1'
			shift
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION] [PATERN]...
				Get a quick mark.

				 -c, --config  quick mark file
				 -C, --colmun  jump to colmun
				 -l, --line    jump to line
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

directory=$(dirname "${config}"; printf '$')
mkdir -p "${directory%?$}"
: >>"${config}"

# オプション以外の引数を再セットする
eval set -- "${args}"

if [ "${#}" -eq 0 ]; then
	set -- $(cat)
fi

goto=''

for pattern in ${@+"${@}"}; do
	fileds=$(grep -e "^${pattern}	" "${config}" || :)

	if [ -z "${goto}" ]; then
		first=$(printf '%s\n' "${fileds}" | head -n 1)
		goto=$(printf '%s' "${first}" | cut -f 2)
		header=$(gotoMove "$(printf '%s' "${first}" | cut -f 3)" "$(printf '%s' "${first}" | cut -f 4)")
		fileds=$(printf '%s\n' "${fileds}" | tail -n '+2'; printf '$')
	fi

	header=$(printf '%s\n%s' "${header}" "$(
		printf '%s' "${fileds%$}" | while IFS='	' read -r 'key' 'uri' 'line' 'colmun' 'date'; do
			printf 'W3m-control: TAB_GOTO %s\n' "${uri}"
			gotoMove "${line}" "${colmun}"
		done
	)")
done

if [ -z "${goto}" ]; then
	httpResponseW3mBack.sh
else
	printRedirect.sh "${goto}" '' "${header}"
fi
