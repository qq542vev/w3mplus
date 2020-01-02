#!/usr/bin/env sh

##
# Execute the command according to the site.
#
# @author qq542vev
# @version 1.1.0
# @date 2020-01-03
# @licence https://creativecommons.org/licenses/by/4.0/
##

# 初期化
set -eu
umask 0022
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# 各変数に既定値を代入する
config="${W3MPLUS_PATH}/autoCommand"
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
				Usage: ${0} [OPTION]... [CALL] [URI]
				Execute the command according to the site.

				 -c, --config=FILE  configuration file
				 -h, --help         display this help and exit
			EOF

			exit
			;;
		# 標準入力を処理する
		'-')
			arg=$( (cat; echo) | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '$');
:
			args="${args}${args:+ }'${arg%?$}'"
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

while [ 1 -le "${#}" ]; do
	operatorCall="${1}"
	string="${2}"

	shift 2

	while IFS='	' read -r 'call' 'check' 'command'; do
		if [ "${operatorCall}" = "${call}" ] && result=$(printf '%s' "${string}" | eval "${check}" 2>'/dev/null'); then
			if [ -z "${command}" ]; then
				printf 'W3m-control: %s\n' "${result}"
			else
				printf 'W3m-control: %s\n' "${command}"
			fi

			break
		fi
	done <"${config}"
done | httpResponseW3mBack.sh -
