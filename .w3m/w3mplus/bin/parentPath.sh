#!/usr/bin/env sh

##
# Access the parent directory.
#
# @author qq542vev
# @version 1.2.0
# @date 2020-01-27
# @copyright Copyright (C) 2019-2020 qq542vev. Some rights reserved.
# @licence CC-BY <https://creativecommons.org/licenses/by/4.0/>
##

# 初期化
set -eu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# 終了時の動作を設定する
trap 'exit 129' 1 # SIGHUP
trap 'exit 130' 2 # SIGINT
trap 'exit 131' 3 # SIGQUIT
trap 'exit 143' 15 # SIGTERM

# 各変数に既定値を代入する
count='1'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-n' | '--number')
			if [ "${2}" != '0' ] && [ "$(expr -- "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2

				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			count="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0##*/} [OPTION]... URI [URI]...
				Access the parent directory.

				 -n, --number   number of go up
				 -h, --help     display this help and exit
				 -v, --version  output version information and exit
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

# オプション以外の引数を再セットする
eval set -- "${args}"

# 引数の個数が過小である
if [ "${#}" -eq 0 ]; then
	set -f
	set -- $(cat)
	set +f
fi

# regular expression of URI
pattern='^\(\([^:\/?#]\{1,\}\):\)\{0,1\}\(\/\/\([^\/?#]*\)\)\{0,1\}\([^?#]*\)\(?\([^#]*\)\)\{0,1\}\(#\(.*\)\)\{0,1\}$'

for uri in ${@+"${@}"}; do
	path=$(printf '%s' "${uri}" | sed -e "s/${pattern}/\\5/")
	tmpCount="${count}"

	while [ "${tmpCount}" -ne 0 ] && [ "${path}" != '/' ]; do
		if expr -- "${path}" ':' '.*/$' >'/dev/null'; then
			path="${path%/*}"
		fi

		path="${path%/*}/"
		tmpCount=$((tmpCount - 1))
	done

	printf '%s%s\n' "$(printf '%s' "${uri}" | sed -e "s/${pattern}/\\1\\3/")" "${path}"
done
