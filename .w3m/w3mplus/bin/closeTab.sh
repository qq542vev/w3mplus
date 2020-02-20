#!/usr/bin/env sh

## File: closeTab.sh
##
## Close the tab and record the URI.
##
## Usage:
##
##   (start code)
##   Usage: closeTab.sh [OPTION]... [URI]...
##   (end)
##
## Options:
##
##   -c, --config=FILE - restore file
##   -h, --help        - display this help and exit
##   -v, --version     - output version information and exit
##
## Exit Status:
##
##   0  - Program terminated normally.
##   1< - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 2.0.1
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
trap 'endCall' 0 # EXIT
trap 'endCall; exit 129' 1 # SIGHUP
trap 'endCall; exit 130' 2 # SIGINT
trap 'endCall; exit 131' 3 # SIGQUIT
trap 'endCall; exit 143' 15 # SIGTERM

: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/functions"

# 各変数に既定値を代入する
config="${W3MPLUS_PATH}/tabRestore"
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
			usage
			exit
			;;
		'-v' | '--version')
			version
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

directory=$(dirname -- "${config}"; printf '$')
mkdir -p -- "${directory%?$}"
: >>"${config}"

# オプション以外の引数を再セットする
eval set -- "${args}"

if [ "${#}" -eq 0 ]; then
	set -f
	set -- $(cat)
	set +f
fi

tmpFile=$(mktemp)
date=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

{
	cat -- "${config}"

	for uri in ${@+"${@}"}; do
		printf '%s\t%s\n' "${uri}" "${date}"
	done
} | awk '
	BEGIN {
		prev["uri"] = ""
		prev["date"] = ""
	}

	NF == 2 {
		if(prev["uri"] != "" && $1 != prev["uri"]) {
			printf("%s\t%s\n", prev["uri"], prev["date"])
		}

		prev["uri"] = $1
		prev["date"] = $2
	}

	END {
		if(prev["uri"] != "") {
			printf("%s\t%s\n", prev["uri"], prev["date"])
		}
	}
' >"${tmpFile}"

cp -fp -- "${tmpFile}" "${config}"
