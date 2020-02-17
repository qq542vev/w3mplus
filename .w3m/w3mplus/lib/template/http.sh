#!/usr/bin/env sh

# 初期化
set -eu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# 終了時の動作を設定する
trap 'exit 129' 1 # SIGHUP
trap 'exit 130' 2 # SIGINT
trap 'exit 131' 3 # SIGQUIT
trap 'exit 143' 15 # SIGTERM

: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/config"

body=''
header=''
status='200 OK'

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-b')
			body="${2}"
			shift 2
			;;
		'-h')
			header="${2}"
			shift 2
			;;
		'-s')
			status="${2}"
			shift 2
			;;
		*)
			# 引数の個数が過大である
			if [ 0 -lt "${#}" ]; then
				cat <<- EOF 1>&2
					${0##*/}: too many arguments
					Try '${0##*/} --help' for more information.
				EOF

				exit 64 # EX_USAGE </usr/include/sysexits.h>
			fi
			;;
	esac
done

case "${LANG:-C}" in
	'C' | 'POSIX')
		languageTag='en'
		;;
	*)
		languageTag=$(printf '%s' "${LANG%%.*}" | tr '_' '-')
		;;
esac

date=$(LANG='C' date -u '+%a, %d %b %Y %H:%M:%S GMT')

printf 'HTTP/1.1 %s\r\n' "${status}"

normalizeHttpMessage.sh <<- EOF
	Date: ${date}
	Cache-Control: no-cache, no-store, must-revalidate, max-age=0
	Pragma: no-cache
	Age: 0
	Server: ${SERVER_SOFTWARE:-w3m} $(uname -s -r | tr ' ' '/')
	Referrer-Policy: no-referrer
	Content-Language: ${languageTag}
	Content-Length: $(printf '%s' "${body}" | wc -c)
	Expires: Thu, 01 Jan 1970 00:00:00 GMT
	Last-Modified: ${date}
	Link: <https://purl.org/meta/me>; rel="author"; title="qq542vev", <https://github.com/qq542vev/w3mplus>; rel="code-repository"; title="w3mplus main repository", <file://$(urlencodeForPath "${W3MPLUS_PATH}")/doc/index.html>; rel="help"; title="w3mplus Document", <https://creativecommons.org/licenses/by-nc/4.0/>; rel="license"; title="Creative Commons License"
	MIME-Version: 1.0
EOF

printf '%s\r\n%s' "${header}" "${body}"
