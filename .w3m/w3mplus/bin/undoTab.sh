#!/usr/bin/env sh

##
# Restore w3m tabs.
#
# @author qq542vev
# @version 2.0.0
# @date 2020-02-12
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

# 終了時に一時ディレクトリを削除する
endCall () {
	rm -fr -- ${tmpFile+"${tmpFile}"}
}

# 各変数に既定値を代入する
config="${W3MPLUS_PATH}/tabRestore"
count='-1'
number='0'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--config')
			config="${2}"
			shift 2
			;;
		'-C' | '--count')
			if [ "$(expr -- "${2}" ':' '@\{0,1\}[+-]0$')" -eq 0 ] && [ "$(expr -- "${2}" ':' '@\{0,1\}[+-][1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a integer or timestamp.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			count="${2}"
			shift 2
			;;
		'-n' | '--number')
			if [ "${2}" != '0' ] && [ "${2}" != '@0' ] && [ "$(expr -- "${2}" ':' '@\{0,1\}[1-9][0-9]*$')" -eq 0 ]; then
				printf 'The option "%s" must be a integer or timestamp.\n' "${1}" 1>&2
				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi

			number="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0##*/} [OPTION]...
				$(sed -e '/^##$/,/^##$/!d; /^# /!d; s/^# //; q' -- "${0}")

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
				${0##*/} (w3mplus) $(sed -n -e 's/^# @version //p' -- "${0}") (Last update: $(sed -n -e 's/^# @date //p' -- "${0}"))
				$(sed -n -e 's/^# @copyright //p' -- "${0}")
				License: $(sed -n -e 's/^# @licence //p' -- "${0}")
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
lineCount=$(grep -c -e '^' -- "${config}" || :)
tmpFile=$(mktemp)

case "${number}" in '@'*)
	case "${count}" in
		'@'*)
			result=$(sed '1!G; h; $!d' -- "${config}" | awk -v "timePosition=${number#@}" -v "timeCount=${count#@}" -- "$(
				cat <<- 'EOF'
				BEGIN {
					position = -1
					count = -1

					if(0 <= timeCount) {
						start = timePosition + timeCount
						end = timePosition
					} else {
						start = timePosition
						end = timePosition + timeCount
					}
				}

				{
					date = $2

					gsub(/[TZ:-]/, "", date)
					gsub(/'+/, "'\"&\"'", date)

					command = "printf '%s' '" date "' | TZ='UTC+0' utconv"
					command | getline timestamp

					if(position < 0 && timestamp <= start) {
						position = NR - 1
					}

					if(0 <= position && timestamp < end) {
						count = NR - position - 1
						exit
					}
				}

				END {
					if(position < 0) {
						position = NR
					}

					if(count < 0) {
						count = NR - position
					}

					printf("%d %s%d\n", position, (position || count) ? "-" : "+", count)
				}
				EOF
			)")
			number="${result% *}"
			count="${result#* }"
			;;
		*)
			number=$(sed '1!G; h; $!d' -- "${config}" | awk -v "time=${number#@}" -v "sign=${count%%[0-9]*}" -- "$(
				cat <<- 'EOF'
				BEGIN {
					number = -1
				}

				{
					date = $2

					gsub(/[TZ:-]/, "", date)
					gsub(/'+/, "'\"&\"'", date)

					command = "printf '%s' '" date "' | TZ='UTC+0' utconv"
					command | getline timestamp

					if((("+" == sign) && (timestamp < time)) || (("-" == sign) && (timestamp <= time))) {
						number = NR - 1
						exit
					}
				}

				END {
					printf("%d", (0 <= number) ? number : NR)
				}
				EOF
			)")
			;;
	esac
	;;
esac

case "${count}" in
	'+0')
		count="${number}"
		number='0'
		;;
	'+'*)
		if [ "${number}" -lt "${count}" ]; then
			count="${number}"
		fi

		number=$((number - count))
		count=$((count))
		;;
	'-0')
		count="${lineCount}"
		;;
	'-'*)
		count=$((count * -1))
		;;
esac

head -n "-$((number + count))" -- "${config}" >>"${tmpFile}"

head -n "-${number}" -- "${config}" | tail -n "${count}" | sed '1!G; h; $!d' | awk -v "limitTime=${limitTime}" -v "file=${tmpFile}" -- "$(
	cat <<- 'EOF'
	{
		date = $2

		gsub(/[TZ:-]/, "", date)
		gsub(/'+/, "'\"&\"'", date)

		command = "printf '%s' '" date "' | TZ='UTC+0' utconv"
		command | getline timestamp

		if(timestamp <= limitTime) {
			gsub(/'+/, "'\"&\"'", file)
			system(": >'" file "'")
			exit
		}

		printf("%s\t%s\n", $1, $2)
	}
	EOF
)"

tail -n "${number}" -- "${config}" >>"${tmpFile}"

cp -fp -- "${tmpFile}" "${config}"
