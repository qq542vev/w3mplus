#!/usr/bin/env sh

## File: lineVisualMode.sh
##
## Start visual mode.
##
## Usage:
##
##   (start code)
##   lineVisualMode.sh [OPTION]... FILE
##   (end)
##
## Options:
##
##   -l, --line=NUMBER - line number
##   -h, --help        - display this help and exit.
##   -v, --version     - output version information and exit.
##
## Exit Status:
##
##   0 - Program terminated normally.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.1.4
##   date - 2020-02-20
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues

# 初期化
set -efu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'


: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/functions"

# 各変数に既定値を代入する
line='1'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-l' | '--line')
			if expr -- "${2}" ':' '[1-9][0-9]*$' >'/dev/null'; then
				line="${2}"
				shift 2
			else
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exitStatus="${EX_USAGE}"; exit
			fi
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
			args="${args}$(quoteEscape ${@+"${@}"})"
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

			exitStatus="${EX_USAGE}"; exit
			;;
		# その他のオプション以外の引数
		*)
			args="${args}$(quoteEscape "${1}")"
			shift
			;;
	esac
done

# オプション以外の引数を再セットする
eval set -- "${args}"

file="${1}"
checksum=$(cksum -- "${file}" | cut -d ' ' -f '1-2' | tr ' ' '-')

# 引数の個数が過大である
if [ 1 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0##*/}: too many arguments
		Try '${0##*/} --help' for more information.
	EOF

	exitStatus="${EX_USAGE}"; exit
fi

: "${W3MPLUS_VISUALSTART:=0	0	0}"

startChecksum=$(printf '%s' "${W3MPLUS_VISUALSTART}" | cut -f 1)
startLine=$(printf '%s' "${W3MPLUS_VISUALSTART}" | cut -f 2)
startTime=$(printf '%s' "${W3MPLUS_VISUALSTART}" | cut -f 3 | tr -d 'TZ:-' | TZ='UTC+0' utconv)

if [ "${checksum}" = "${startChecksum}" ] && [ "$(date -u '+%Y%m%d%H%M%S' | TZ='UTC+0' utconv)" -lt "$((startTime + W3MPLUS_VISUAL_TIMEOUT))" ]; then
	selectLine.sh -l "${startLine}" -n "${line}" 'yank' "${file}"
	printf 'W3m-control: SETENV W3MPLUS_VISUALSTART=\r\n'
else
	httpResponseW3mBack.sh - <<- EOF
		W3m-control: SETENV W3MPLUS_VISUALSTART=${checksum}	${line}	$(date -u '+%Y-%m-%dT%H:%M:%SZ')
		W3m-control: EXEC_SHELL printf 'Start visual mode from line %d\\n' '${line}'
	EOF
fi
