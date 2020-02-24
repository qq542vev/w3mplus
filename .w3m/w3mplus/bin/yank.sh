#!/usr/bin/env sh

## File: yank.sh
##
## Yank text with w3m.
##
## Usage:
##
##   (start code)
##   yank.sh [OPTION]... [TEXT]...
##   (end)
##
## Options:
##
##   -f, --file=FILE     - yank file
##   -F, --footer=STRING - footer text
##   -H, --header=STRING - header text
##   -h, --help          - display this help and exit.
##   -v, --version       - output version information and exit.
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
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

# 初期化
set -efu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'


: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/functions"

# 各変数に既定値を代入する
yankFile=$(date "+${W3MPLUS_YANK_FILE}"; printf '$');
yankFile="${yankFile%?$}"
yankHeader=$(date "+${W3MPLUS_YANK_HEADER}"; printf '$');
yankHeader="${yankHeader%?$}"
yankFooter=$(date "+${W3MPLUS_YANK_FOOTER}"; printf '$');
yankFooter="${yankFooter%?$}"
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-f' | '--file')
			yankFile="${2}"
			shift 2
			;;
		'-F' | '--footer')
			yankFooter="${2}"
			shift 2
			;;
		'-H' | '--header')
			yankHeader="${2}"
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
			arg=$( (cat; echo) | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '$');

			args="${args}${args:+ }'${arg%?$}'"
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

			exitStatus="${EX_USAGE}"; exit
			;;
		# その他のオプション以外の引数
		*)
			arg=$(printf '%s\n' "${1}" | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '$');

			args="${args}${args:+ }'${arg%?$}'"
			shift
			;;
	esac
done

directory=$(dirname -- "${yankFile}"; printf '$')
mkdir -p -- "${directory%?$}"

# オプション以外の引数を再セットする
eval set -- "${args}"

if [ "${#}" -eq 0 ]; then
	set -- "$(cat)"
fi

tmpFile=$(mktemp)

for yankText in ${@+"${@}"}; do
		printf '%s%s%s' "${yankHeader}" "${yankText}" "${yankFooter}" >>"${tmpFile}"
done

cat -- "${tmpFile}" >>"${yankFile}"
count=$(grep -c -e '^' -- "${tmpFile}" || :)

httpResponseW3mBack.sh "W3m-control: EXEC_SHELL cat -- '${tmpFile}'; rm -f -- '${tmpFile}'; printf \"\\nAdd %d lines to '%s'\\n\" '${count}' '${yankFile}'"
