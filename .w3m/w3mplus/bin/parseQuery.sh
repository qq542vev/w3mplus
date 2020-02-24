#!/usr/bin/env sh

## File: parseQuery.sh
##
## Parse the HTTP query.
##
## Usage:
##
##   (start code)
##   parseQuery.sh [OPTION]... [FILE]...
##   (end)
##
## Options:
##
##   -p, --prefix   variable prefix
##   -s, --suffix   variable suffix
##   -h, --help     display this help and exit.
##   -v, --version  output version information and exit.
##
## Exit Status:
##
##   0 - Program terminated normally.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.1.3
##   date - 2020-02-20
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

# 初期化
set -efu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# initファイルの読み込み
: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/init"

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
			usage
			exit
			;;
		# バージョン情報を表示して終了する
		'-v' | '--version')
			version
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

			exitStatus="${EX_USAGE}"; exit
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
