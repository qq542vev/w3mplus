#!/usr/bin/env sh

## File: html.sh
##
## Default HTML template for w3mplus.
##
## Usage:
##
##   (start code)
##   html.sh [OPTION]...
##   (end)
##
## Options:
##
##   -c - main content
##   -m - meta data
##   -t - title
##
## Exit Status:
##
##   0 - Program terminated normally.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.1
##   date - 2020-02-20
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
. "${W3MPLUS_PATH}/lib/w3mplus/init"

mainCintent=''
metaData=''
title='No title'

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c')
			mainContent="${2}"
			shift 2
			;;
		'-m')
			metaData="${2}"
			shift 2
			;;
		'-t')
			title="${2}"
			shift 2
			;;
		*)
			# 引数の個数が過大である
			if [ 0 -lt "${#}" ]; then
				cat <<- EOF 1>&2
					${0##*/}: too many arguments
					Try '${0##*/} --help' for more information.
				EOF

				exitStatus="${EX_USAGE}"; exit
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

cat <<- EOF
	<!DOCTYPE html>
	<html
		xmlns="http://www.w3.org/1999/xhtml"
		lang="${languageTag}"
		xml:lang="${languageTag}"
		about=""
		typeof="foaf:Document"
	>
		<head>
			<meta charset="UTF-8" />
			<meta name="author" property="dc11:creator" content="qq542vev" />
			<meta name="copyright" property="dc11:rights" lang="en" xml:lang="en" content="Copyright © 2019 - 2020 qq542vev. Some rights reserved." />
			<meta name="generator" content="w3mplus" />
			<meta name="referrer" content="no-referrer" />
			<meta name="robots" content="noindex,nofollow,noarchive" />

			<title property="dcterms:title">$(printf '%s' "${title}" | htmlEscape.sh)</title>

			<link rel="author" title="qq542vev" href="https://purl.org/meta/me" />
			<link rel="code-repository" title="w3mplus main repository" href="https://github.com/qq542vev/w3mplus" />
			<link rel="help" title="w3mplus Document" href="file://$(urlencodeForPath "${W3MPLUS_PATH}")/doc/index.html" />
			<link rel="license" title="Creative Commons License" href="https://creativecommons.org/licenses/by-nc/4.0/" />
			${metaData}
		</head>
		<body>
			<main id="main" rel="schema:mainContentOfPage" resource="#main">${mainContent}</main>
		</body>
	</html>
EOF
