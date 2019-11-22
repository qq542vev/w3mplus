#!/usr/bin/env sh

set -eu

uri="${1:-}"
beforeHeader="${2:-}"
afterHeader="${3:-}"

if expr "${uri}" ':' '[0-9A-Za-z]\{1,\}:' >'/dev/null'; then
	if [ "${W3MPLUS_REDIRECT_TYPE:-0}" -eq '1' ]; then
		command="W3m-control: TAB_GOTO ${uri}"
	else
		command="W3m-control: GOTO ${uri}"
	fi

	body="<p>Redirecting: <a href=\"${uri}\">${uri}</a></p>"
else
	command="W3m-control: ${uri}"
	body="<p>Redirecting: <code>${uri}</code></p>"
fi

if [ -z "${uri}" ]; then
	if [ "${W3MPLUS_REDIRECT_TYPE:-0}" -eq '2' ]; then
		httpResponseNoCache.sh '' 'W3m-control: CLOSE_TAB'
	else
		httpResponseW3mBack.sh
	fi

	exit 0
fi

if [ "${W3MPLUS_REDIRECT_TYPE:-0}" -eq '2' ]; then
	printHtml.sh 'Redirecting' "${body}" "$(
		cat <<- EOF
			${beforeHeader}
			${command}
			W3m-control: DELETE_PREVBUF
			${afterHeader}
		EOF
	)"

	exit 0
fi

httpResponseNoCache.sh '' - <<- EOF
	${beforeHeader}
	W3m-control: BACK
	${command}
	${afterHeader}
EOF
