#!/usr/bin/env sh

##
# Execute the command according to the site.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-24
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

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

				 -c, --config  configuration file
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

directory=$(dirname "${config}"; printf '_')
mkdir -p "${directory%?_}"
: >>"${config}"

# オプション以外の引数を再セットする
eval set -- "${args}"

operatorCall="${1-manual}"
uri="${2-${W3M_URL}}"

# 引数の個数が過大である
if [ 2 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0}: too many arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

while read -r 'call' 'regType' 'pattern' 'command'; do
	if [ "${operatorCall}" = "${call}" ] && expr "${regType}" ':' '!\{0,1\}[EFG]$' >'/dev/null'; then
		grepOption=$(printf '%s' "${regType}" | sed -e 's/^!/ -v/; s/[FEG]$/ -&/')

		if printf '%s' "${uri}" | grep ${grepOption} -q -e "${pattern}"; then
			printf 'W3m-control: COMMAND %s\n' "${command}"
			break
		fi
	fi
done <"${config}" | httpResponseW3mBack.sh -
