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
##   -E, --extended-regexp - PATTERNS are extended regular expressions
##   -h, --help            - display this help and exit.
##   -v, --version         - output version information and exit.
##
## Exit Status:
##
##   0 - Program terminated normally.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 2.0.0
##   date - 2020-03-21
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
		'-E' | '--extended-regexp')
			regexpFlag='1'
			shift
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

directory=$(dirname -- "${config}"; printf '$')
mkdir -p -- "${directory%?$}"
: >>"${config}"

# オプション以外の引数を再セットする
eval set -- "${args}"

# 引数の個数が過小である
if [ "${#}" -eq 0 ]; then
	set -- $(cat)
fi

result=$(for pattern in ${@+"${@}"}; do
	printf '%s\n' "${pattern}"
done | awk -v "config=${config}" -v "regexpFlag=${regexpFlag}" -- '
	{
		pattern = $0

		if(!regexpFlag) {
			sub(/[].\*+?|(){}[]/, "\\\\&", pattern)
		}

		pattern = "^" pattern "$"

		while(0 < (getline < config)) {
			if($1 ~ pattern) {
				printf("%s\n", $0)
			}
		}

		close(config)
	}
')

case "${result}" in
	'')
		exitStatus='1'
		;;
	*)
		printf '%s\n' "${result}"
		;;
esac
