#!/usr/bin/env sh

##
# Access the parent directory.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-11
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

# 各変数に既定値を代入する
count='1'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-n' | '--number')
			if [ "${2}" != '0' ] && [ "$(expr "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2

				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			count="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... URI [URI]...
				Access the parent directory.

				 -n, --number  number of go up
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
			option=$(printf '%s' "${1}" | cut -c '2'; printf '$')
			options=$(printf '%s' "${1}" | cut -c '3-'; printf '$')

			shift
			# `-abc` を `-a -bc` に変換して再セットする
			set -- "-${option%$}" "-${options%$}" ${@+"${@}"}
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

# オプション以外の引数を再セットする
eval set -- "${args}"

pattern='^\(\([^:\/?#]\{1,\}\):\)\{0,1\}\(\/\/\([^\/?#]*\)\)\{0,1\}\([^?#]*\)\(?\([^#]*\)\)\{0,1\}\(#\(.*\)\)\{0,1\}$'

# 引数の個数が過小である
if [ "${#}" -eq 0 ]; then
	cat <<- EOF 1>&2
		${0}: not enough arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

for uri in ${@+"${@}"}; do
	path=$(printf '%s' "${uri}" | sed -e "s/${pattern}/\\5/")

	tmpCount="${count}"

	while [ "${tmpCount}" -ne 0 ] && [ "${path}" != '/' ]; do
		if expr "${path}" ':' '.*/$' >'/dev/null'; then
			path="${path%/*}"
		fi

		path="${path%/*}/"

		tmpCount=$((tmpCount - 1))
	done

	printf '%s%s\n' "$(printf '%s' "${uri}" | sed -e "s/${pattern}/\\1\\3/")" "${path}"
done
