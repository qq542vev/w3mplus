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
