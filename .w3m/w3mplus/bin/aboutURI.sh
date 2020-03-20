#!/usr/bin/env sh

## File: aboutURI.sh
##
## Displays a page about w3m.
##
## Usage:
##
##   (start code)
##   aboutURI.sh [ABOUT_URI]
##   (end)
##
## Options:
##
## Exit Status:
##
##   0 - Program terminated normally.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.4.0
##   date - 2020-03-21
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

# initファイルの読み込み
: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/init"

case "${1-about:about}" in
	'about:')
		printf '<pre title="w3m Version Information"><samp>%s</samp></pre>' "$(w3m -version | htmlescape)" | printHtml.sh --title 'About:'
		;;
	'about:about')
		printHtml.sh --title 'About About' <<- 'EOF'
			<section>
				<h1>About About</h1>

				<p>This is a list of “about” pages for your convenience.</p>

				<ul>
					<li><a href="about:">about:</a></li>
					<li><a href="about:about">about:about</a></li>
					<li><a href="about:blank">about:blank</a></li>
					<li><a href="about:bookmark">about:bookmark</a></li>
					<li><a href="about:cache">about:cache</a></li>
					<li><a href="about:config">about:config</a></li>
					<li><a href="about:cookie">about:cookie</a></li>
					<li><a href="about:downloads">about:downloads</a></li>
					<li><a href="about:help">about:help</a></li>
					<li><a href="about:history">about:history</a></li>
					<li><a href="about:home">about:home</a></li>
					<li><a href="about:memory">about:memory</a></li>
					<li><a href="about:message">about:message</a></li>
					<li><a href="about:newtab">about:newtab</a></li>
					<li><a href="about:permissions">about:permissions</a></li>
					<li><a href="about:private">about:private</a></li>
					<li><a href="about:preferences">about:preferences</a></li>
				</ul>
			</section>
		EOF
		;;
	'about:blank')
		: | printHtml.sh --title 'about:blank'
		;;
	'about:bookmark')
		httpResponseW3mBack.sh 'W3m-control: VIEW_BOOKMARK'
		;;
	'about:cache')
		w3mhome="${HOME}/.w3m"
		fileurl="file://$(printf '%s' ${w3mhome} | urlencode | fsed '%2F' '/')/"

		awkScript=$(
			cat <<- 'EOF'
			BEGIN {
				monthListCount = split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", monthList)

				for(i = 1; i <= monthListCount; i++) {
					monthList[monthList[i]] = i
				}

				command = "date '+%Y %m'"
				command | getline
				close(command)

				currentYear = $1
				currentMonth = $2

				totalSize = 0

				printf("<tbody rel=\"rdf:li\">")
			}

			index($0, "-") == 1 && $7 ~ /^w3m(cache|cookie|frame|src|tmp)[.0-9A-Z_a-z-]*$/ {
				fileSize = $3
				fileMonth = monthList[$4]
				fileDay = $5
				fileYear = $6
				fileName = $7

				totalSize += fileSize

				if(index(fileYear, ":")) {
					fileYear = currentYear - (currentMonth < fileMonth)
				}

				date = sprintf("%04d-%02d-%02d", fileYear, fileMonth, fileDay)

				printf("<tr typeof=\"schema:DigitalDocument\"><td><a property=\"foaf:name\" rel=\"owl:sameAs\" href=\"%s\">%s</a></td><td property=\"dc11:format\" datatype=\"xsd:nonNegativeInteger\">%s</td><td property=\"dcterms:modified\" content=\"%s\" datatype=\"dcterms:W3CDTF\"><time datetime=\"%s\">%s</time></td></tr>", fileurl fileName, fileName, fileSize, date, date, $4 " " $5 " " $6)
			}

			END {
				printf("</tbody>")
				printf("<tfoot><tr><th scope=\"row\">Total Size</th><td>%s</td><td></td></tr></tfoot>", totalSize)
			}
			EOF
		)

		printHtml.sh --title 'Network Cache Storage Information' <<- EOF
			<table typeof="rdf:Seq">
				<caption property="dcterms:title">w3m Cache Files in '<a rel="dcterms:relation" href="${fileurl}">${w3mhome}</a>'</caption>
				<thead>
					<tr>
						<th scope="col">File Name</th>
						<th scope="col">Size(Byte)</th>
						<th scope="col">Modified</th>
					</tr>
				</thead>
				$(LANG='C' ls -go "${w3mhome}" | awk -v "fileurl=${fileurl}" -- "${awkScript}")
			</table>
		EOF
		;;
	'about:config')
		printRedirect.sh "file://$(printf '%s' "${W3MPLUS_W3M_CONFIG}" | urlencode | fsed '%2F' '/')"
		;;
	'about:cookie')
		httpResponseW3mBack.sh 'W3m-control: COOKIE'
		;;
	'about:downloads')
		httpResponseW3mBack.sh 'W3m-control: DOWNLOAD_LIST'
		;;
	'about:help')
		httpResponseW3mBack.sh 'W3m-control: HELP'
		;;
	'about:history')
		httpResponseW3mBack.sh 'W3m-control: HISTORY'
		;;
	'about:home')
		printHtml.sh --title 'w3m Start Page' --header-field "$(
			cat <<- 'EOF'
				W3m-control: BEGIN
				W3m-control: NEXT_LINK
			EOF
		)" <<- EOF
			<form action="file:///cgi-bin/w3mplus" method="get" accept-charset="UTF-8">
				<p align="center">
					<input type="hidden" name="action" value="search" />
					<input accesskey="s" type="text" name="query" size="30" placeholder="Search Keywords" />
				</p>
			</form>

			<p align="center">
				<a accesskey="~" href="file://$(printf '%s' "${HOME}" | urlencode | fsed '%2F' '/')">Home</a> -
				<a accesskey="b" href="about:bookmark">Bookmarks</a> -
				<a accesskey="h" href="about:history">History</a> -
				<a accesskey="d" href="about:downloads">Downloads</a>
			</p>

			<p align="center">
				<a accesskey="?" href="about:help">Help</a> -
				<a accesskey="o" href="about:config">Options</a> -
				<a accesskey="c" href="about:cookie">Cookies</a> -
				<a accesskey="m" href="about:message">Messages</a>
			</p>

			<p align="center"><samp>$(printf '%s' "${SERVER_SOFTWARE:-w3m}" | htmlescape)</samp></p>
		EOF
		;;
	'about:memory')
		header='pid=,ppid=,pcpu=,vsz=,nice=,etime=,time=,args='
		awkScript='
			BEGIN {
				headerCount = split("Process ID,Parent process ID,Ratio of CPU time,Memory usage,Nice value,Elapsed time,Cumulative CPU time,Command", header, /,/)
				split("S M H DT", timeUnit)
			}

			{
				printf("<table><tbody>")

				for(i = 1; i <= headerCount; i++) {
					printf("<tr><th>%s</th><td>", header[i])

					if(i == 3) {
						printf("%s%%", $i)
					} else if(i == 4) {
						printf("%s KiB", $i)
					} else if((i == 6) || (i == 7)) {
						count = split($i, time, /[:-]/)

						datetime = "P"
						for(j = 1; j <= count; j++) {
							datetime = datetime (time[j] + 0) timeUnit[count - j + 1]
						}

						printf("<time datetime=\"%s\">%s</time>", datetime, $i)
					} else if(i == headerCount) {
						printf("%s", $i)

						for(j = headerCount + 1; j <= NF; j++) {
							printf(" %s", $j)
						}
					} else {
						printf("%s", $i)
					}

					printf("</td></tr>")
				}

				printf("</tbody></table>")
			}
		'

		if w3mid=$(ancestorProsess "${$}" 'w3m'); then
			cat <<- EOF
				<section>
					<h1>Current w3m process<h1>

					$(ps -o "${header}" -p "${w3mid}" | htmlescape | awk -- "${awkScript}")
				</section>

				<section>
					<h1>Other w3m processes<h1>

					$(ps -o "${header}" | awk -v "pid=${w3mid}" -- '($1 != pid) && ($8 == "w3m") { print $0 }'| htmlescape | awk -- "${awkScript}")
				</section>
			EOF
		fi | printHtml.sh --title 'w3m processes'
		;;
	'about:message')
		httpResponseW3mBack.sh 'W3m-control: MSGS'
		;;
	'about:newtab')
		httpResponseW3mBack.sh 'W3m-control: TAB_GOTO about:blank'
		;;
	'about:permissions')
		printRedirect.sh "file://$(printf '%s' "${HOME}" | urlencode | fsed '%2F' '/')/.w3m/siteconf"
		;;
	'about:preferences')
		httpResponseW3mBack.sh 'W3m-control: OPTIONS'
		;;
	'about:private')
		printHtml.sh --title 'Private Browsing' <<- 'EOF'
			<h1>Private Browsing</h1>

			<p>w3m won't remember any history for this window.</p>

			<p>In a Private Browsing window, w3m won't keep any browser history, search history, download history, web form history, cookies, or temporary internet files. However, files you download and bookmarks you make will be kept.</p>

			<p>To stop Private Browsing, you can close this window.</p>

			<p>While this computer won't have a record of your browsing history, your internet service provider or employer can still track the pages you visit.</p>
		EOF
		;;
	*)
		printHtml.sh --title 'Problem loading page' --status-code '400 Bad Request' <<- 'EOF'
			<h1>The address isn't valid</h1>

			<p>The URL is not valid and cannot be loaded.</p>

			<ul>
				<li>Web addresses are usually written like <strong>http://www.example.com/</strong></li>
				<li>Make sure that you're using forward slashes (i.e. /).</li>
			</ul>
		EOF
		;;
esac
