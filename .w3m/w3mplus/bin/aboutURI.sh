#!/usr/bin/env sh

##
# Displays a page about w3m.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-12-20
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

case "${1-about:about}" in
	'about:')
		printHtml.sh 'About:' "<pre title=\"w3m Version Information\"><samp>$(w3m -version | htmlEscape.sh)</samp></pre>"
		;;
	'about:about')
		printHtml.sh 'About About' - <<- 'EOF'
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
		printHtml.sh 'about:blank'
		;;
	'about:bookmark')
		printRedirect.sh 'VIEW_BOOKMARK'
		;;
	'about:cache')
		printRedirect.sh "file://${HOME}/.w3m"
		;;
	'about:config')
		printRedirect.sh 'OPTIONS'
		;;
	'about:cookie')
		printRedirect.sh 'COOKIE'
		;;
	'about:downloads')
		printRedirect.sh 'DOWNLOAD_LIST'
		;;
	'about:help')
		printRedirect.sh 'HELP'
		;;
	'about:history')
		printRedirect.sh 'HISTORY'
		;;
	'about:home')
		printHtml.sh 'w3m Start Page' - "$(
			cat <<- 'EOF'
				W3m-control: BEGIN
				W3m-control: LINE_BEGIN
				W3m-control: NEXT_LINK
			EOF
		)" <<- EOF
			<form action="about:search" method="get" accept-charset="UTF-8">
				<p align="center">
					<input type="hidden" name="action" value="search" />
					<input accesskey="s" type="text" name="query" size="30" placeholder="Search Keywords" />
				</p>
			</form>

			<p align="center">
				<a accesskey="~" href="file://${HOME}">Home</a> -
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

			<p align="center"><samp>$(printf '%s' "${SERVER_SOFTWARE:-w3m}" | htmlEscape.sh)</samp></p>
		EOF
		;;
	'about:message')
		printRedirect.sh 'MSGS'
		;;
	'about:newtab')
		httpResponseW3mBack.sh 'W3m-control: TAB_GOTO about:blank'
		;;
	'about:permissions')
		printRedirect.sh "file://${HOME}/.w3m/siteconf"
		;;
	*)
		printHtml.sh 'Problem loading page' - '' '400 Bad Request' <<- 'EOF'
			<h1>The address isn't valid</h1>

			<p>The URL is not valid and cannot be loaded.</p>

			<ul>
				<li>Web addresses are usually written like <strong>http://www.example.com/</strong></li>
				<li>Make sure that you're using forward slashes (i.e. /).</li>
			</ul>
		EOF
		;;
esac
