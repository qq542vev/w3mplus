#!/usr/bin/env sh

##
# Increments the URI.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-20
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

# 各変数に既定値を代入する
number='+1'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-n' | '--number')
			if [ "${2}" != '0' ] && [ "$(expr "${2}" ':' '[+-]\{0,1\}[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a integer.\n' "${1}" 1>&2

				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			number="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... URI [URI]...
				Increments the URI.

				 -n, --number  increment number
				 -h, --help    display this help and exit
			EOF

			exit
			;;
		# 標準入力を処理する
		'-')
			args="${args}$(tr '[:space:]' '\n' | while IFS= read -r uri; do
				printf " '"
				printf '%s' "${uri}" | sed -e "s/'\\{1,\\}/'\"&\"'/g"
				printf "'"
			done)"
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

# 引数の個数が過小である
if [ "${#}" -eq 0 ]; then
	cat <<- EOF 1>&2
		${0}: not enough arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

for uri in ${@+"${@}"}; do
	parts=$(printf '%s' "${uri}" | sed -e 's/\([:\/?#@&*=_-]\)\([0-9]\{1,\}\)/\1\n\2\n/g')
	line=$(printf '%s' "${parts}" | sed -n -e '/^[0-9]\{1,\}$/=' | tail -n '1')

	if [ -n "${line}" ]; then
		page=$(printf '%s' "${parts}" | sed -n -e "${line}p")

		if printf '%s' "${number}" | grep -q -e '^[0-9]\{1,\}$'; then
			page="${number}"
		else
			page="$((page + number))"

			if [ "${page}" -lt 0 ]; then
				page='0'
			fi
		fi

		printf '%s' "${parts}" | sed -e "${line}c ${page}" | tr -d '\n'
		printf '\n'
	fi
done
