#!/usr/bin/env sh

##
# Normalize HTTP message.
#
# @author qq542vev
# @version 1.0.0
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

endCall () {
	rm -fr ${tmpDir+"${tmpDir}"}
}

token="[!#-'*+.^_\`|~A-Za-z0-9-]\\{1,\\}"
tmpDir=$(mktemp -d)

case "${LANG:-C}" in
	'*.[A-Za-z0-9]*')
		charset="${LANG#*.}"
		;;
	*)
		charset='UTF-8'
		;;
esac

output='start,header,body'
uncombine='Set-Cookie'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--charset')
			if expr "${2}" ':' "${token}\$" >'/dev/nul'; then
				charset="${2}"
				shift 2
			else
				cat <<- EOF 1>&2
					${0##*/}: invalid option -- '${1}'
					Possible values: Character Set
				EOF

				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi
			;;
		'-i' | '--in-place')
			suffix="${2}"
			shift 2
			;;
		'-o' | '--output')
			case "${1}" in 'start' | 'header' | 'body' | 'start,header' | 'start,body' | 'header,body' | 'start,header,body')
				cat <<- EOF 1>&2
					${0##*/}: invalid option -- '${1}'
					Possible values: start[,header][,body] or header[,body] or body.
				EOF

				exit 64 # EX_USAGE </usr/include/sysexits.h>
			esac

			output="${2}"
			shift 2
			;;
		'-u' | '--uncombine')
			if expr "${2}" ':' "\\(${token}\\(,${token}\\)*\\)\\{0,1\\}\$" >'/dev/null'; then
				uncombine="${2}"
				shift 2
			else
				cat <<- EOF 1>&2
					${0##*/}: invalid option -- '${1}'
					Possible values: HTTP header name
				EOF

				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi
			;;
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0##*/} [OPTION]... [FILE]...
				$(sed -e '/^##$/,/^##$/!d; /^# /!d; s/^# //; q' -- "${0}")

				 -c, --charset=STRING    header charset
				 -i, --in-place=SUFFIX   edit files in place (makes backup if SUFFIX supplied)
				 -o, --output=STRING     start, header, body
				 -u, --uncombine=STRING  uncombine headers
				 -h, --help              display this help and exit
				 -v, --version           output version information and exit
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
			tmpFile=$(mktemp -p "${tmpDir}")
			cat >"${tmpFile}"
			shift

			set -- "${tmpFile}" ${@+"${@}"}
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

# オプション以外の引数を再セットする
eval set -- "${args}"

# 引数の個数が過小である
if [ "${#}" -eq 0 ]; then
	tmpFile=$(mktemp -p "${tmpDir}")
	cat >"${tmpFile}"

	set -- "${tmpFile}"
fi

awkScript=$(cat << 'EOF'
	BEGIN {
		split("", header)
		headerCount = split("", headerOrder)
		currentHeader = ""
		emptyLine = 0
		output = "," output ","
		uncombine = "," tolower(uncombine) ","
	}

	function fieldValue(string, command) {
		gsub(/[\t\r ]+/, " ", string)
		gsub(/^ +| +$/, "", string)

		if(match(string, /[^\t -~]/)) {
			gsub(/'+/, "'\"&\"'", string)

			command = "printf '%s' '" string "' | base64 | tr -d '\\n'"
			command | getline string

			return sprintf("=?%s?B?%s?=", charset, string)
		}

		return string
	}

	/^[!#-'*+.^_`|~A-Za-z0-9-]+:/ {
		i = index($0, ":")
		name = substr($0, 0, i)
		lowerName = tolower(name)

		if(index(uncombine, "," tolower(lowerName) ",")) {
			lowerName = lowerName "@" NR
		}

		currentHeader = lowerName

		if(lowerName in header) {
			header[lowerName] = header[lowerName] ","
		} else {
			header[lowerName] = name ": "
			headerOrder[++headerCount] = lowerName
		}

		header[lowerName] = header[lowerName] fieldValue(substr($0, i + 1))
		next
	}

	currentHeader != "" && /^[\t ]/ {
		header[currentHeader] = header[currentHeader] " " fieldValue($0)
		next
	}

	/^\r?$/ {
		emptyLine = 1
		exit
	}

	index(output, ",start,") && NR == 1 && /^[!#-'*+.^_`|~A-Za-z0-9-]/ {
		gsub(/\r$/, "", $0)
		printf("%s\r\n", $0)
	}

	END {
		if(index(output, ",header,")) {
			for(i = 1; i <= headerCount; i++) {
				printf("%s\r\n", header[headerOrder[i]])
			}
		}

		if(emptyLine && index(output, ",body,")) {
			if(index(output, ",start,") || index(output, ",header,")) {
				printf("\r\n")
			}

			while(0 < getline) {
				printf("%s\n", $0)
			}
		}
	}
EOF
)

tmpFile=$(mktemp -p "${tmpDir}")

for file in ${@+"${@}"}; do
	awk -v "charset=${charset}" -v "output=${output}" -v "uncombine=${uncombine}" -- "${awkScript}" "${file}" >"${tmpFile}"

	if [ "${suffix+1}" = '1' ]; then
		cp -fp -- "${tmpFile}" "${file}"
	else
		cat -- "${tmpFile}"
	fi
done