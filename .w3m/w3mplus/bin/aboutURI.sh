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
##   version - 1.0.4
##   date - 2020-02-27
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
				<li><a href="about:history">about:help</a></li>
				<li><a href="about:home">about:home</a></li>
				<li><a href="about:message">about:message</a></li>
				<li><a href="about:newtab">about:newtab</a></li>
				<li><a href="about:permissions">about:permissions</a></li>
			</ul>
		EOF
		;;
	'about:blank')
		: | printHtml.sh --title 'about:blank'
		;;
	'about:bookmark')
		httpResponseW3mBack.sh 'W3m-control: VIEW_BOOKMARK'
		;;
	'about:cache')
		printRedirect.sh "file://$(urlencodeForPath "${HOME}")/.w3m"
		;;
	'about:config')
		httpResponseW3mBack.sh 'W3m-control: OPTIONS'
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
				<a accesskey="~" href="file://$(urlencodeForPath "${HOME}")">Home</a> -
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
	'about:message')
		httpResponseW3mBack.sh 'W3m-control: MSGS'
		;;
	'about:newtab')
		httpResponseW3mBack.sh 'W3m-control: TAB_GOTO about:blank'
		;;
	'about:permissions')
		printRedirect.sh "file://$(urlencodeForPath "${HOME}")/.w3m/siteconf"
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
