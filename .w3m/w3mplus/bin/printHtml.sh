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

case "${LANG:-C}" in 'C')
	LANG='en_US.US-ASCII'
	;;
esac

lang=$(printf '%s' "${LANG%%.*}" | tr '_' '-')
charset="${LANG#*.}"

title="${1-No title}"
main="${2-}"
header=$(printf '%s\nContent-Type: text/html; charset=%s' "${3-}" "${charset}")
statusCode="${4-200 OK}"

case "${main}" in '-')
	main=$(cat)
	;;
esac

httpResponseNoCache.sh - "${header}" "${statusCode}" <<- EOF
	<!DOCTYPE html>
	<html
		xmlns="http://www.w3.org/1999/xhtml"
		lang="${lang}"
		xml:lang="${lang}"
		about=""
		typeof="foaf:Document"
	>
		<head>
			<meta charset="${charset}" />
			<meta name="copyright" property="dc11:rights" content="Copyright © 2019 qq542vev. Some rights reserved." />
			<meta name="generator" content="w3mplus" />
			<meta name="referrer" content="no-referrer" />

			<title property="dcterms:title">${title}</title>

			<link rel="author" title="qq542vev - GitHub" href="https://github.com/qq542vev" />
			<link rel="help" title="w3mplus Document" href="file://${W3MPLUS_PATH}/doc/index.html" />
			<link rel="license" title="Creative Commons License" href="https://creativecommons.org/licenses/by-nc/4.0/" />
		</head>
		<body>
			<main id="main" rel="schema:mainContentOfPage" resource="#main">${main}</main>
		</body>
	</html>
EOF
