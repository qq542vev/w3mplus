#!/usr/bin/env sh

## File: getQuickMark.sh
##
## Get a quick mark.
##
## Usage:
##
##   (start code)
##   getQuickMark.sh [OPTION]... [PATTERN]...
##   (end)
##
## Options:
##
##   -c, --config=FILE     - quick mark file
##   -C, --colmun          - jump to colmun
##   -E, --extended-regexp - PATTERNS are extended regular expressions
##   -l, --line            - jump to line
##   -h, --help            - display this help and exit
##   -v, --version         - output version information and exit
##
## Exit Status:
##
##   0  - Program terminated normally.
##   1< - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.2.1
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
set -efu
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
config="${W3MPLUS_PATH}/quickmark"
moveColmun='0'
moveLine='0'
regexpFlag='0'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--config')
			config="${2}"
			shift 2
			;;
		'-C' | '--colmun')
			moveColmun='1'
			shift
			;;
		'-E' | '--extended-regexp')
			regexpFlag='1'
			shift
			;;
		'-l' | '--line')
			moveLine='1'
			shift
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

			exit 64 # EX_USAGE </usr/include/sysexits.h>
			;;
		# その他のオプション以外の引数
		*)
			args="${args}$(quoteEscape "${1}")"
			shift
			;;
	esac
done

directory=$(dirname -- "${config}"; printf '$')
mkdir -p -- "${directory%?$}"
: >>"${config}"

# オプション以外の引数を再セットする
eval set -- "${args}"

# 引数の個数が過小である
if [ "${#}" -eq 0 ]; then
	set -- $(cat)
fi

awkScript=$(cat <<- 'EOF'
	BEGIN {
		if(!regexpFlag) {
			sub(/[].\*+?|(){}[]/, "\\\\&", pattern)
		}

		pattern = "^" pattern "$"

		jumpListCount = split("line colmun", jumpList, " ")

		data["line"] = moveLine
		data["line_goto"] = "GOTO_LINE %s"
		data["line_end"] = "END"
		data["line_up"] = "MOVE_UP %s"

		data["colmun"] = moveColmun
		data["colmun_goto"] = "COMMAND LINE_BEGIN; MOVE_RIGHT1 %s"
		data["colmun_end"] = "LINE_END"
		data["colmun_up"] = "MOVE_LEFT1 %s"
	}

	function quoteEscape(string) {
		gsub(/'+/, "'\"&\"'", string)
		return "'" string "'"
	}

	function w3mCommand(command) {
		return sprintf("W3m-control: %s\n", command)
	}

	$1 ~ pattern {
		uri = $2
		data["line_number"] = $3
		data["colmun_number"] = $4
		headerField = ""

		for(i = 1; i <= jumpListCount; i++) {
			if(data[jumpList[i]]) {
				if(0 < data[jumpList[i] "_number"]) {
					headerField = headerField w3mCommand(sprintf(data[jumpList[i] "_goto"], data[jumpList[i] "_number"]))
				} else {
					headerField = headerField w3mCommand(data[jumpList[i] "_end"])

					if(data[jumpList[i] "_number"] < 0) {
						headerField = headerField w3mCommand(sprintf(data[jumpList[i] "_up"], data[jumpList[i] "_number"] * -1))
					}
				}
			}
		}

		printf(" '--header-field' %s %s", quoteEscape(headerField), quoteEscape(uri))
	}
EOF
)

arguments='printRedirect.sh'

for pattern in ${@+"${@}"}; do
	arguments="${arguments}$(awk -v "pattern=${pattern}" -v "regexpFlag=${regexpFlag}" -v "moveLine=${moveLine}" -v "moveColmun=${moveColmun}" -- "${awkScript}" "${config}")"
done

eval "${arguments}"
