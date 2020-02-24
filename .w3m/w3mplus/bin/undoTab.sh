#!/usr/bin/env sh

## File: undoTab.sh
##
## Restore w3m tabs.
##
## Usage:
##
##   (start code)
##   undoTab.sh [OPTION]...
##   (end)
##
## Options:
##
##   -c, --config=FILE   - restore file
##   -C, --count=NUMBER  - restore count
##   -n, --number=NUMBER - restore number
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
##   version - 2.1.0
##   date - 2020-02-21
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
null='/dev/null'
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
			if expr -- "${2}" ':' '@\{0,1\}[+-]0$' >"${null}" || expr -- "${2}" ':' '@\{0,1\}[+-][1-9][0-9]*$' >"${null}"; then
				count="${2}"
				shift 2
			else
				printf 'The option "%s" must be a integer or timestamp.\n' "${1}" 1>&2
				exitStatus="${EX_USAGE}"; exit
			fi
			;;
		'-n' | '--number')
			if [ "${2}" = '0' ] || [ "${2}" = '@0' ] || expr -- "${2}" ':' '@\{0,1\}[1-9][0-9]*$' >"${null}"; then
				number="${2}"
				shift 2
			else
				printf 'The option "%s" must be a integer or timestamp.\n' "${1}" 1>&2
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

	exitStatus="${EX_USAGE}"; exit
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
					datetime = $NF

					gsub(/[TZ:-]/, "", datetime)
					gsub(/'+/, "'\"&\"'", datetime)

					command = "printf '%s' '" datetime "' | TZ='UTC+0' utconv"
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
					datetime = $NF

					gsub(/[TZ:-]/, "", datetime)
					gsub(/'+/, "'\"&\"'", datetime)

					command = "printf '%s' '" datetime "' | TZ='UTC+0' utconv"
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
		datetime = $NF

		gsub(/[TZ:-]/, "", datetime)
		gsub(/'+/, "'\"&\"'", datetime)

		command = "printf '%s' '" datetime "' | TZ='UTC+0' utconv"
		command | getline timestamp

		if(timestamp <= limitTime) {
			gsub(/'+/, "'\"&\"'", file)
			system(": >'" file "'")
			exit
		}

		printf("%s\n", $0)
	}
	EOF
)"

tail -n "${number}" -- "${config}" >>"${tmpFile}"

cp -fp -- "${tmpFile}" "${config}"
