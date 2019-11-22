#!/usr/bin/env sh

##
# Display w3m dialog.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-07
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

case "${1}" in
	'bookmark')
		printRedirect.sh 'VIEW_BOOKMARK'
		;;
	'cookie')
		printRedirect.sh 'COOKIE'
		;;
	'download')
		printRedirect.sh 'DOWNLOAD_LIST'
		;;
	'help')
		printRedirect.sh 'HELP'
		;;
	'history')
		printRedirect.sh 'HISTORY'
		;;
	'option')
		printRedirect.sh 'OPTIONS'
		;;
	'message')
		printRedirect.sh 'MSGS'
		;;
	*)
		printHtml.sh 'Problem loading page' - '' '404 Not Found' <<- 'EOF'
			<h1>The address isn't valid</h1>

			<p>The URL is not valid and cannot be loaded.</p>

			<ul>
				<li>Web addresses are usually written like <strong>http://www.example.com/</strong></li>
				<li>Make sure that you're using forward slashes (i.e. /).</li>
			</ul>
		EOF
		;;
esac
