#!/usr/bin/env sh

set -eu

date=$(LANG='C' date -u '+%a, %d %b %Y %H:%M:%S GMT')

body="${1-}"
header="${2-}"
statusCode="${3-200 Ok}"

case "${body}" in '-')
	body=$(cat; printf '_');
	body="${body%_}"
	;;
esac

case "${header}" in '-')
	header=$(cat; printf '_')
	header="${header%_}"
	;;
esac

printf 'HTTP/1.1 %s\r\n' "${statusCode}"

httpHeader.sh <<- EOF
	Date: ${date}
	Expires: Thu, 01 Jan 1970 00:00:00 GMT
	Cache-Control: no-cache, no-store, must-revalidate, max-age=0
	Pragma: no-cache
	Last-Modified: ${date}
	Server: ${SERVER_SOFTWARE:-w3m}
	Link: <https://github.com/qq542vev>; rel="author"; title="qq542vev - GitHub", <file://${W3MPLUS_PATH}/doc/index.html>; rel="help"; title="w3mplus Document", <https://creativecommons.org/licenses/by-nc/4.0/>; rel="license"; title="Creative Commons License"
	${header}
EOF

if [ -n "${body}" ]; then
	printf '\r\n%s' "${body}"
fi
