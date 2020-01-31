#!/usr/bin/env sh

##
# Restore w3m tabs.
#
# @author qq542vev
# @version 1.2.2
# @date 2020-01-27
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

# 終了時に一時ディレクトリを削除する
endCall () {
	rm -fr -- ${tmpDir+"${tmpDir}"}
}

# 各変数に既定値を代入する
config="${W3MPLUS_PATH}/tabRestore"
count='1'
number='+1'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--config')
			config="${2}"
			shift 2
			;;
		'-C' | '--count')
			if [ "${2}" != '0' ] && [ "$(expr -- "${2}" ':' '[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a positive integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			count="${2}"
			shift 2
			;;
		'-n' | '--number')
			if [ "$(expr -- "${2}" ':' '[+-][1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a integer.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			number="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0##*/} [OPTION]...
				Restore w3m tabs.

				 -c, --config=FILE    restore file
				 -C, --count=NUMBER   restore count
				 -n, --number=NUMBER  restore number
				 -h, --help           display this help and exit
				 -v, --version        output version information and exit
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

# 引数の個数が過大である
if [ 0 -lt "${#}" ]; then
	cat <<- EOF 1>&2
		${0##*/}: too many arguments
		Try '${0##*/} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

limitTime=$(($(date -u '+%Y%m%d%H%M%S' | TZ='UTC+0' utconv) - W3MPLUS_UNDO_TIMEOUT))
tmpFile=$(mktemp)
lineCount=$(grep -c -e '^' -- "${config}" || :)

if [ 1 -le "${number}" ]; then
	end=$((lineCount - number + 1))
	start=$((end - count + 1))

	if [ 1 -le "${end}" ]; then
		if [ "${count}" -eq 0 ] || [ "${start}" -lt 1 ]; then
			start='1'
		fi

		head -n "$((start - 1))" -- "${config}" >"${tmpFile}"

		sed -e "${start},${end}!d" -- "${config}" | sed -e '1!G; h; $!d' | while IFS='	' read -r 'uri' 'date'; do
			timestamp=$(printf '%s' "${date}" | tr -d 'TZ:-' | TZ='UTC+0' utconv)

			if [ "${limitTime}" -lt "${timestamp}" ]; then
				printf 'W3m-control: TAB_GOTO %s\n' "${uri}"
			else
				: >"${tmpFile}"
				break
			fi
		done

		tail -n "+$((end + 1))" -- "${config}" >>"${tmpFile}"

		cp -fp -- "${tmpFile}" "${config}"
	fi
elif [ "${number}" -lt 0 ]; then
	start=$((number * -1))
	end=$((start + count - 1))
	if [ "${count}" -eq 0 ]; then
		end="${lineCount}"
	fi
	index='1'

	while IFS='	' read -r 'uri' 'date'; do
		if [ "${end}" -lt "${index}" ]; then
			printf '%s %s\n' "${uri}" "${date}" >>"${tmpFile}"
			continue
		fi

		timestamp=$(printf '%s' "${date}" | tr -d 'TZ:-' | TZ='UTC+0' utconv)

		if [ "${limitTime}" -lt "${timestamp}" ]; then
			if [ "${number}" -le "${index}" ]; then
				printf 'W3m-control: TAB_GOTO %s\n' "${uri}"
			else
				printf '%s %s\n' "${uri}" "${date}" >>"${tmpFile}"
			fi

			index=$((index + 1))
		fi
	done <"${config}"

	cp -fp -- "${tmpFile}" "${config}"
fi | httpResponseW3mBack.sh -
