#!/usr/bin/env shellspec

## File: abouturi_spec.sh
##
## Test abouturi.
##
## Usage:
##
##   (start code)
##   shellspec abouturi_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.1
##   date - 2020-09-12
##   since - 2020-06-11
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test abouturi'
	abouturi () {
		env 'W3MPLUS_TEMPLATE_HTTP=template/http' "${W3MPLUS_PATH}/bin/abouturi" ${@+"${@}"}
	}

	output () {
		cat <<- EOF
			HTTP/1.1 200 OK${SHELLSPEC_CR}
			Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
		EOF

		for field in ${@+"${@}"}; do
			printf '%s\r\n' "${field}"
		done

		printf '\r\n'
	}

	Example 'No arguments'
		When call abouturi
		The output should equal "$(abouturi 'about:about')"
	End

	Example 'Bad request'
		output () {
			%text:expand
			#|HTTP/1.1 400 Bad Request${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|Content-Type: text/html; charset=UTF-8${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
		}

		When call abouturi 'about:bad'
		The output should start with "$(output)"
	End

	Example "Test about:home"
		When call abouturi 'about:home'
		The output should start with "$(output 'Content-Type: text/html; charset=UTF-8' 'W3m-control: BEGIN' 'W3m-control: NEXT_LINK')"
	End

	Describe 'Test abouturi'
		Parameters
			'about:bookmark' 'VIEW_BOOKMARK'
			'about:config' "GOTO file://${HOME}/.w3m/config"
			'about:cookie' 'COOKIE'
			'about:downloads' 'DOWNLOAD_LIST'
			'about:help' 'HELP'
			'about:history' 'HISTORY'
			'about:message' 'MSGS'
			'about:newtab' 'TAB_GOTO about:blank'
			'about:permissions' "GOTO file://${HOME}/.w3m/siteconf"
			'about:preferences' 'OPTIONS'
		End

		Example "Test ${1}"
			When call abouturi "${1}"
			The output should equal "$(output 'W3m-control: BACK' "W3m-control: ${2}")"
		End
	End

	Describe 'Test abouturi'
		Parameters
			'about:'
			'about:about'
			'about:blank'
			'about:cache'
			'about:memory'
			'about:private'
		End

		Example "Test ${1}"
			When call abouturi "${1}"
			The output should start with "$(output 'Content-Type: text/html; charset=UTF-8')"
		End
	End
End
