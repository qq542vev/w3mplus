#!/usr/bin/env sh

##
# Close the tab and record the URI.
#
# @author qq542vev
# @version 2.0.0
# @date 2020-02-08
# @copyright Copyright (C) 2019-2020 qq542vev. Some rights reserved.
# @licence CC-BY <https://creativecommons.org/licenses/by/4.0/>
##

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
. "${W3MPLUS_PATH}/config"

# 終了時に一時ファイルを削除する
endCall () {
	rm -f -- ${tmpFile+"${tmpFile}"}
}

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
			cat <<- EOF
				Usage: ${0##*/} [OPTION]... [URI]...
				$(sed -e '/^##$/,/^##$/!d; /^# /!d; s/^# //; q' -- "${0}")

				 -c, --config=FILE  restore file
				 -h, --help         display this help and exit
				 -v, --version      output version information and exit
			EOF

			exit
			;;
		'-v' | '--version')
			cat <<- EOF
				${0##*/} (w3mplus) $(sed -n -e 's/^# @version //1p' -- "${0}") (Last update: $(sed -n -e 's/^# @date //1p' -- "${0}"))
				$(sed -n -e 's/^# @copyright //1p' -- "${0}")
				License: $(sed -n -e 's/^# @licence //1p' -- "${0}")
			EOF

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
