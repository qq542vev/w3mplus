#!/usr/bin/env sh

## File: normalizeHttpMessage.sh
##
## Normalize HTTP message.
##
## Usage:
##
##   (start code)
##   normalizeHttpMessage.sh [OPTION]... [FILE]...
##   (end)
##
## Options:
##
##   -c, --charset=STRING           - header charset
##   -i, --in-place=SUFFIX          - edit files in place (makes backup if SUFFIX supplied)
##   -o, --output=STRING            - start, header, body
##   -u, --uncombined=HEADER_NAME   - uncombined headers
##   -U, --unstructured=HEADER_NAME - uncombined headers
##   -h, --help                     - display this help and exit
##   -v, --version                  - output version information and exit
##
## Exit Status:
##
##   0  - Program terminated normally.
##   1< - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.5
##   date - 2020-02-20
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues

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
. "${W3MPLUS_PATH}/lib/w3mplus/functions"

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
uncombined='Set-Cookie'
unstructured=''
args=''

unset 'suffix'

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--charset')
			if expr "${2}" ':' "${token}\$" >'/dev/null'; then
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
			case "${2}" in
				'start' | 'header' | 'body' | 'start,header' | 'start,body' | 'header,body' | 'start,header,body')
					output="${2}"
					shift 2
					;;
				*)
					cat <<- EOF 1>&2
						${0##*/}: invalid option -- '${1}'
						Possible values: start[,header][,body] or header[,body] or body.
					EOF

					exit 64 # EX_USAGE </usr/include/sysexits.h>
					;;
			esac
			;;
		'-u' | '--uncombined')
			if expr "${2}" ':' "\\(${token}\\(,${token}\\)*\\)\\{0,1\\}\$" >'/dev/null'; then
				uncombined="${2}"
				shift 2
			else
				cat <<- EOF 1>&2
					${0##*/}: invalid option -- '${1}'
					Possible values: HTTP header name
				EOF

				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi
			;;
		'-U' | '--unstructured')
			if expr "${2}" ':' "\\(${token}\\(,${token}\\)*\\)\\{0,1\\}\$" >'/dev/null'; then
				unstructured="${2}"
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
			usage
			exit
			;;
		'-v' | '--version')
			version
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
		split("", headerName)
		split("", headerValue)
		headerCount = split("", headerOrder)
		emptyLine = 0
		uncombined = "," tolower(uncombined) ","
		unstructured = "," tolower(unstructured) ","
	}

	function fieldValue(string, charset) {
		gsub(/^[	 ]/, "", string)
		return fieldContentToken(string, charset)
	}

	function encodeBase64(string, charset, command) {
		if(charset == "") {
			charset = "UTF-8"
		}

		gsub(/'+/, "'\"&\"'", string)

		command = "printf '%s' '" string "' | base64 | tr -d '\\n'"
		command | getline string

		return sprintf("=?%s?B?%s?=", charset, string)
	}

	function fieldContentToken(string, charset, delimiter,after,count) {
		delimiter = ""
		after = ""

		if(match(string, /["(),\/:;<=>?@\[\\\]{}]/)) {
			delimiter = substr(string, RSTART, RLENGTH)
			after = substr(string, RSTART + RLENGTH)
			string = substr(string, 1, RSTART - 1)
		} else {
			gsub(/[	 ]+$/, "", string)
		}

		gsub(/[	 ]+/, " ", string)
		count = split(string, array, / /)
		string = ""

		for(; 0 < count; count--) {
			string = (array[count] ~ /[^ -~]/ ? encodeBase64(array[count], charset) : array[count]) string

			if(count != 1) {
				string = " " string
			}
		}

		if(delimiter == "\"") {
			string = string delimiter fieldContentQuotedString(after, charset)
		} else if(delimiter == "(") {
			string = string delimiter fieldContentComment(after, charset)
		} else if(delimiter != "") {
			string = string delimiter fieldContentToken(after, charset)
		}

		return string
	}

	function fieldContentQuotedString(string, charset, delimiter,after) {
		delimiter = ""
		after = ""

		if(match(string, /\\\\?|\\?"/)) {
			delimiter = substr(string, RSTART, RLENGTH)
			after = substr(string, RSTART + RLENGTH)
			string = substr(string, 1, RSTART - 1)
		}

		if(delimiter == "\"") {
			string = string delimiter fieldContentToken(after, charset)
		} else if((delimiter == "\\\\") || (delimiter == "\\\"")) {
			string = string delimiter fieldContentQuotedString(after, charset)
		} else if(delimiter == "\\") {
			if(after == "") {
				string = string "\\" delimiter fieldContentQuotedString(after, charset)
			} else {
				string = string fieldContentQuotedString(after, charset)
			}
		} else {
			string = string "\""
		}

		return string
	}

	function fieldContentComment(string, charset, depth, delimiter,after) {
		if(depth == "") {
			depth = 1
		}

		delimiter = ""
		after = ""

		if(match(string, /\\\\?|\\?[()]/)) {
			delimiter = substr(string, RSTART, RLENGTH)
			after = substr(string, RSTART + RLENGTH)
			string = substr(string, 1, RSTART - 1)
		}

		if(string ~ /[^ -~]/) {
			string = encodeBase64(string, charset)
		}

		if(delimiter == "(") {
			string = string delimiter fieldContentComment(after, charset, ++depth)
		} else if(delimiter == ")") {
			if(--depth) {
				string = string delimiter fieldContentComment(after, charset, depth)
			} else {
				string = string delimiter fieldContentToken(after, charset)
			}
		} else if((delimiter == "\\\\") || (delimiter == "\\(") || (delimiter == "\\)")) {
			string = string delimiter fieldContentComment(after, charset, depth)
		} else if(delimiter == "\\") {
			if(after == "") {
				string = string "\\" delimiter fieldContentComment(after, charset, depth)
			} else {
				string = string fieldContentComment(after, charset, depth)
			}
		} else {
			for(; 0 < depth; depth--) {
				string = string ")"
			}
		}

		return string
	}

	function unstructuredField(string, charset) {
		gsub(/^[	 ]+|[	 ]+$/, "", string)

		return (string ~ /[^	 -~]/ ? encodeBase64(string, charset) : string)
	}

	/^[!#-'*+.^_`|~A-Za-z0-9-]+:/ {
		i = index($0, ":")
		name = substr($0, 0, i)
		lowerName = tolower(name)

		if(index(uncombined, "," tolower(lowerName) ",")) {
			lowerName = lowerName "@" NR
		}

		if(lowerName in headerName) {
			headerValue[lowerName] = headerValue[lowerName] ","
		} else {
			headerName[lowerName] = name
			headerOrder[++headerCount] = lowerName
		}

		headerValue[lowerName] = headerValue[lowerName] substr($0, i + 1)
		next
	}

	headerCount && /^[\t ]/ {
		headerValue[headerOrder[headerCount]] = headerValue[headerOrder[headerCount]] $0
		next
	}

	/^\r?$/ {
		emptyLine = 1
		exit
	}

	NR == 1 && index(output, "start") && /^[!#-'*+.^_`|~A-Za-z0-9-]/ {
		gsub(/\r$/, "", $0)
		printf("%s\r\n", $0)
	}

	END {
		if(index(output, "header")) {
			for(i = 1; i <= headerCount; i++) {
				printf("%s: ", headerName[headerOrder[i]])

				if(index(unstructured, "," tolower(headerName[headerOrder[i]]) ",")) {
					printf("%s\r\n", unstructuredField(headerValue[headerOrder[i]], charset))
				} else {
					printf("%s\r\n", fieldValue(headerValue[headerOrder[i]], charset))
				}
			}
		}

		if(emptyLine && index(output, "body")) {
			if(0 < getline && (index(output, "start") || index(output, "header"))) {
				printf("\r\n")
			}

			printf("%s", $0)

			while(0 < getline) {
				printf("\n%s", $0)
			}
		}
	}
EOF
)

tmpFile=$(mktemp -p "${tmpDir}")

for file in ${@+"${@}"}; do
	(cat "${file}"; echo) | awk -v "charset=${charset}" -v "output=${output}" -v "uncombined=${uncombined}" -v "unstructured=${unstructured}" -- "${awkScript}" >"${tmpFile}"

	if [ "${suffix+1}" = '1' ]; then
		cp -fp -- "${tmpFile}" "${file}${suffix}"
	else
		cat -- "${tmpFile}"
	fi
done
