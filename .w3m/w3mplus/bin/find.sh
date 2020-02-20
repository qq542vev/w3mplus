#!/usr/bin/env sh

## File: find.sh
##
## Search for a word.
##
## Usage:
##
##   (start code)
##   find.sh [OPTION]... [WORD]...
##   (end)
##
## Options:
##
##   -e, --exact         - exact search
##   -n, --number=NUMBER - search count
##   -h, --help          - display this help and exit
##   -v, --version       - output version information and exit
##
## Exit Status:
##
##   0  - Program terminated normally.
##   1< - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.1.2
##   date - 2020-02-19
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues

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

: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/functions"

# 各変数に既定値を代入する
exactFlag='0'
number='+1'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-e' | '--exact')
			exactFlag='1'
			shift
			;;
		'-n' | '--number')
			if [ "$(expr -- "${2}" ':' '[+-][1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			number="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			usage
			exit
			;;
		'-v' | '--version')
			version
			exit
			;;
		# 標準入力を処理する
		'-')
			arg=$( (cat; echo) | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '$');

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

if [ "${#}" -eq 0 ]; then
	set -- "$(cat)"
fi

keyword=''

for word in ${@+"${@}"}; do
	if [ -n "${word}" ]; then
		keyword="${keyword}${keyword:+|}$(printf '%s' "${word}" | tr '\n' ' ' | sed -e 's/[].\*+?|(){}[]/\\&/g; 1s/^^/\\^/; $s/$$/\\$/')"
	fi
done

if [ -n "${keyword}" ]; then
	if [ "${exactFlag}" -eq 1 ]; then
		keyword="(^|[	 ])(${keyword})([	 ]|\$)"
	fi

	while [ "${number}" -ne 0 ]; do
		if [ "${exactFlag}" -eq 1 ] && [ "${number}" -lt 0 ]; then
			printf 'W3m-control: MOVE_LEFT1\n'
		fi

		if [ "${number}" -lt 0 ]; then
			printf 'W3m-control: SEARCH_BACK %s\n' "${keyword}"
			number=$((number + 1))
		else
			printf 'W3m-control: SEARCH %s\n' "${keyword}"
			number=$((number - 1))
		fi

		if [ "${exactFlag}" -eq 1 ]; then
			printf 'W3m-control: MOVE_RIGHT1\n'
		fi
	done
fi | httpResponseW3mBack.sh -
