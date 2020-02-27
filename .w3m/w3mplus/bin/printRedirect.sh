#!/usr/bin/env sh

## File: printRedirect.sh
##
## Print redirect message.
##
## Usage:
##
##   (start code)
##   printRedirect.sh [[OPTION]... [URI]]...
##   (end)
##
## Options:
##
## -H, --header-field=HEADER - HTTP header field after redirect
## -h, --help                - display this help and exit.
## -v, --version             - output version information and exit.
##
## Exit Status:
##
##   0 - Program terminated normally.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.1
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

# 各変数に既定値を代入する
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
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
			shift

			awkScript=$(cat <<- 'EOF'
				$0 != "" {
					gsub(/'+/, "'\"&\"'", $0)
					printf("'%s' ", $0)
				}
			EOF
			)

			args="${args}$(awk "${awkScript}")"
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
	if uricheck -f '' "${uri}"; then
		case "${W3MPLUS_REDIRECT_TYPE-0}" in
			'1')
				printf 'W3m-control: TAB_GOTO %s\n' "${uri}"
				W3MPLUS_REDIRECT_TYPE='0'
				;;
			*)
				printf 'W3m-control: GOTO %s\n' "${uri}"
				;;
		esac
	else
		printf '%s\n' "${uri}"
	fi
done | httpResponseW3mBack.sh -
