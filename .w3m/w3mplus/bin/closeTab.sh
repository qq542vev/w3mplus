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
##   -c, --config=FILE   - restore file
##   -C, --colmun=NUMBER - colmun number
##   -l, --line=NUMBER   - line number
##   -h, --help          - display this help and exit
##   -v, --version       - output version information and exit
##
## Exit Status:
##
##   0 - Program terminated normally.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 2.1.0
##   date - 2020-02-21
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues

# 初期化
set -efu
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
colmun='1'
line='1'
fields=''
datetime=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

setFieldList() {
	for uri in ${@+"${@}"}; do
		if uricheck -q "${uri}"; then
			fields=$(printf '%s%s\t%d\t%d\t%s\n$' "${fields}" "${uri}" "${line}" "${colmun}" "${datetime}")
			fields="${fields%$}"
		else
			printf "%s: not URI -- '%s'\\n" "${0##*/}" "${1}" 1>&2
			exit 64 # EX_USAGE </usr/include/sysexits.h>
		fi
	done
}

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--config')
			config="${2}"
			shift 2
			;;
		'-C' | '--colmun')
			colmun="${2}"
			shift 2
			;;
		'-l' | '--line')
			line="${2}"
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
			setFieldList $(cat)
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
			setFieldList ${@+"${@}"}
			shift "${#}"
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
			setFieldList "${1}"
			shift
			;;
	esac
done

directory=$(dirname -- "${config}"; printf '$')
mkdir -p -- "${directory%?$}"
: >>"${config}"

tmpFile=$(mktemp)

{
	cat -- "${config}"
	printf '%s' "${fields}"
} | awk '
	BEGIN {
		split("", previous)
	}

	function printArray(array) {
		if(array[1] != "") {
			printf("%s\t%s\t%s\t%s\n", array[1], array[2], array[3], array[4])
		}
	}

	NF == 4 {
		if($1 != previous[1]) {
			printArray(previous)
		}

		split($0, previous, FS)
	}

	END {
		printArray(previous)
	}
' >"${tmpFile}"

cp -fp -- "${tmpFile}" "${config}"
