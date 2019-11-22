#!/usr/bin/env sh

set -eu

case "${LANG:-C}" in 'C')
	LANG='en_US.ASCII'
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
			<meta name="referrer" content="no-referrer" />
			<meta name="generator" content="w3m plus" />

			<title property="dcterms:title">${title}</title>

			<link rel="license" title="Creative Commons License" href="https://creativecommons.org/licenses/by-nc/4.0/" />
		</head>
		<body>
			<main id="main" rel="schema:mainContentOfPage" resource="#main">${main}</main>
		</body>
	</html>
EOF
