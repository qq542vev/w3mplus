#!/usr/bin/env sh

## File: parentPath.sh
##
## Access the parent directory.
##
## Usage:
##
##   (start code)
##   parentPath.sh [OPTION]... [URI]...
##   (end)
##
## Options:
##
##   -n, --number  - number of go up.
##   -h, --help    - display this help and exit.
##   -v, --version - output version information and exit.
##
## Exit Status:
##
##   0 - Program terminated normally.
##   1 - There are command line arguments other than URI.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.2.3
##   date - 2020-02-27
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
count='1'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-n' | '--number')
			if [ "${2}" = '0' ] || expr -- "${2}" ':' '[1-9][0-9]*$' >'/dev/null'; then
				count="${2}"
				shift 2
			else
				cat <<- EOF 1>&2
					${0##*/}: invalid option value -- '${1}'
					Try '${0##*/} --help' for more information.
				EOF

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

for uri in ${@+"${@}"}; do
	if path=$(uricheck --field 'path' --normalize -- "${uri}"); then
		printf '%s%s\n' "$(uricheck --field 'scheme!,authority!' --normalize -- "${uri}" | tr -d '\t')" "$(printf '%s' "${path}" | sed -e 's/\/$//' | awk -F '/' -v "count=${count}" -- '
			{
				printf("%s", $1)

				if(2 <= NF) {
					printf("/")
				}

				for(i = 2; i <= (NF - count); i++) {
					printf("%s/", $i)
				}
			}
		')"
	else
		printf "%s: not a URI -- '%s'\\n" "${0##*/}" "${uri}" 1>&2
		exitStatus='1'
	fi
done
