#!/usr/bin/env sh

## File: setQuickMark.sh
##
## Set a quick mark.
##
## Usage:
##
##   (start code)
##   setQuickMark.sh [OPTION]... KEY [URI]...
##   (end)
##
## Options:
##
##   -c, --config=FILE    quick mark file
##   -C, --colmun=NUMBER  colmun number
##   -l, --line=NUMBER    line number
##   -h, --help           display this help and exit.
##   -v, --version        output version information and exit.
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
##   date - 2020-02-27
##   since - 2019-07-29
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
colmun='1'
line='1'
fields=''
addList=''
date=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
unset 'key'

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--congig')
			config="${2}"
			shift 2
			;;
		'-C' | '--colmun')
			if [ "${2}" = '0' ] || expr -- "${2}" ':' '-\{0,1\}[1-9][0-9]*$' >'/dev/null'; then
				colmun="${2}"
				shift 2
			else
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exitStatus="${EX_USAGE}"; exit
			fi
			;;
		'-l' | '--line')
			if [ "${2}" = '0' ] || expr -- "${2}" ':' '-\{0,1\}[1-9][0-9]*$' >'/dev/null'; then
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
			case "${key+1}" in
				'1')
					fields=$(printf '%s%s\t%s\t%d\t%d\t%s\n$' "${fields}" "${key}" "${1}" "${line}" "${colmun}" "${date}")
					fields="${fields%$}"
					escapedURI=$(printf '%s' "${1}" | htmlescape)
					addList="${addList}<li><a href=\"${escapedURI}\">${escapedURI}</a></li>"
					;;
				*)
					key="${1}"
					;;
				esac

				shift
			;;
	esac
done

directory=$(dirname -- "${config}"; printf '$')
mkdir -p -- "${directory%?$}"
: >>"${config}"

escapedKey=$(printf '%s' "${key}" | sed 's/[].\*/[]/\\&/g')

deleteList=$(grep -e "^${escapedKey}	" -- "${config}" | cut -f '2' | htmlescape | sed -e 's/^.*$/<li><a href="&">&<\/a><\/li>/')

if [ -z "${addList}" ] && [ -z "${deleteList}" ]; then
	httpResposeW3mBack.sh
	exit
fi

{
	sed -e "/^\$/d; /^${escapedKey}	/d" -- "${config}"
	printf '%s' "${fields}"
} | sort -o "${config}"

if [ -n "${addList}" ]; then
	addList="<h1>Added Quick Mark</h1><ul>${addList}</ul>"
fi

if [ -n "${deleteList}" ]; then
	deleteList="<h1>Deleted Quick Mark</h1><ul>${deleteList}</ul>"
fi

printf "<p>Set Quick Mark '<strong>%s</strong>'</p>%s" "${key}" "${addList}${deleteList}" | printHtml.sh  --title "Set Quick Mark '${key}'" --http-template ''
