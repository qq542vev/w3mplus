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
##   version - 1.0.0
##   date - 2020-06-11
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
	setup() {
		command='../../.w3m/w3mplus/bin/abouturi'
	}

  Before 'setup'

	Example 'No arguments'
		When call "${command}"
		The line 1 of output should equal "HTTP/1.1 200 OK${SHELLSPEC_CR}"
	End

	Example 'Bad request'
		When call "${command}" 'about:bad'
		The line 1 of output should equal "HTTP/1.1 400 Bad Request${SHELLSPEC_CR}"
	End

	Parameters
		'about:'
		'about:about'
		'about:blank'
		'about:bookmark'
		'about:cache'
		'about:config'
		'about:cookie'
		'about:downloads'
		'about:help'
		'about:history'
		'about:home'
		'about:memory'
		'about:message'
		'about:newtab'
		'about:permissions'
		'about:private'
		'about:preferences'
	End

	Example 'About URLs'
		When call "${command}" "${1}"
		The line 1 of output should equal "HTTP/1.1 200 OK${SHELLSPEC_CR}"
	End
End
