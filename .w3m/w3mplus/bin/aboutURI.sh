#!/usr/bin/env sh

##
# Displays a page about w3m.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-07
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

case "${1-about:about}" in
	'about:')
		printHtml.sh 'About:' "<pre title=\"w3m Version Information\"><samp>$(w3m -version)</samp></pre>"
		;;
	'about:about')
		printHtml.sh 'About About' - <<- 'EOF'
			<h1>About About</h1>

			<p>This is a list of “about” pages for your convenience.</p>

			<ul>
				<li><a href="about:">about:</a></li>
				<li><a href="about:about">about:about</a></li>
				<li><a href="about:blank">about:blank</a></li>
				<li><a href="about:cache">about:cache</a></li>
				<li><a href="about:config">about:config</a></li>
				<li><a href="about:downloads">about:downloads</a></li>
				<li><a href="about:home">about:home</a></li>
				<li><a href="about:newtab">about:newtab</a></li>
				<li><a href="about:permissions">about:permissions</a></li>
			</ul>
		EOF
		;;

	'about:blank')
		printHtml.sh 'about:blank'
		;;
	'about:cache')
		httpResponseNoCache.sh '' - <<- EOF
			W3m-control: LOAD ${HOME}/.w3m
			W3m-control: DELETE_PREVBUF
		EOF
		;;
	'about:config')
		httpResponseNoCache.sh '' - <<- 'EOF'
			W3m-control: OPTIONS
			W3m-control: DELETE_PREVBUF
		EOF
		;;
	'about:downloads')
		httpResponseW3mBack.sh 'W3m-control: DOWNLOAD_LIST'
		;;
	'about:home')
		printHtml.sh 'w3m Start Page' - "$(
			cat <<- 'EOF'
				W3m-control: BEGIN
				W3m-control: LINE_BEGIN
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
				<a accesskey="~" href="file://${HOME}">Home</a> -
				<a accesskey="b" href="file:///cgi-bin/w3mplus?action=dialog&page=bookmark&redirect=2">Bookmarks</a> -
				<a accesskey="h" href="file:///cgi-bin/w3mplus?action=dialog&page=history&redirect=2">History</a> -
				<a accesskey="d" href="file:///cgi-bin/w3mplus?action=dialog&page=download">Downloads</a>
			</p>

			<p align="center">
				<a accesskey="?" href="file:///cgi-bin/w3mplus?action=dialog&page=help&redirect=2">Help</a> -
				<a accesskey="o" href="file:///cgi-bin/w3mplus?action=dialog&page=option&redirect=2">Options</a> -
				<a accesskey="c" href="file:///cgi-bin/w3mplus?action=dialog&page=cookie">Cookies</a> -
				<a accesskey="m" href="file:///cgi-bin/w3mplus?action=dialog&page=message&redirect=2">Messages</a>
			</p>

			<p align="center"><samp>${SERVER_SOFTWARE:-w3m}</samp></p>
		EOF
		;;
	'about:newtab')
		httpResponseW3mBack.sh 'W3m-control: TAB_GOTO about:blank'
		;;
	'about:permissions')
		httpResponseW3mBack.sh "W3m-control: LOAD ${HOME}/.w3m/siteconf"
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
