#!/usr/bin/env sh

##
# Parse the HTTP query.
#
# @author qq542vev
# @version 1.1.2
# @date 2020-02-13
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

quoteEscape () (
	sed -e "s/'\{1,\}/'\"&\"'/g"
)

getQuery () (
	IFS='&'
	set -f
	set -- $(cat)

	while [ 1 -le "${#}" ]; do
		if [ -n "${1}" ]; then
			key=$(printf '%s' "${1%%=*}" | urldecode | quoteEscape)
			value=$(
				if [ "${1}" != "${1#*=}" ]; then
					printf '%s' "${1#*=}" | urldecode | quoteEscape
				fi
			)

			if [ -z "${prefix+1}" ] && [ -z "${suffix+1}" ]; then
				printf '%s %s' "'${key}'" "'${value}'"

				if [ "${#}" -eq 1 ]; then
					printf '\n'
				else
					printf ' '
				fi
			elif expr -- "${key}" ':' '[_A-Za-z][_0-9A-Za-z]*$' >'/dev/null'; then
				printf '%s%s%s=%s\n' "${prefix-}" "${key}" "${suffix-}" "'${value}'"
			fi
		fi

		shift
	done
)

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-p' | '--prefix')
			prefix="${2}"
			shift 2
			;;
		'-s' | '--suffix')
			suffix="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0##*/} [OPTION]... [FILE]...
				$(sed -e '/^##$/,/^##$/!d; /^# /!d; s/^# //; q' -- "${0}")

				 -p, --prefix   variable prefix
				 -s, --suffix   variable suffix
				 -h, --help     display this help and exit
				 -v, --version  output version information and exit
			EOF

			exit
			;;
		'-v' | '--version')
			cat <<- EOF
				${0##*/} (w3mplus) $(sed -n -e 's/^# @version //p' -- "${0}") (Last update: $(sed -n -e 's/^# @date //p' -- "${0}"))
				$(sed -n -e 's/^# @copyright //p' -- "${0}")
				License: $(sed -n -e 's/^# @licence //p' -- "${0}")
			EOF

			exit
			;;
		# 標準入力を処理する
		'-')
			query="${query-}${query:+&}$(cat)"

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
				query="${query-}${query:+&}$(cat -- "${1}")"
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
			query="${query-}${query:+&}$(cat -- "${1}")"
			shift
			;;
	esac
done

if [ -z "${query+1}" ]; then
	query="$(cat)"
fi

printf '%s' "${query}" | getQuery
