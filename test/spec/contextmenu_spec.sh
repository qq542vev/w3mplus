#!/usr/bin/env shellspec

## File: contextmenu_spec.sh
##
## Test uricheck.
##
## Usage:
##
##   (start code)
##   shellspec contextmenu_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-06-28
##   since - 2020-06-28
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test contextmenu'
	setup() {
		command='../../.w3m/w3mplus/bin/contextmenu'
		newline="${SHELLSPEC_CR}${SHELLSPEC_LF}${SHELLSPEC_CR}${SHELLSPEC_LF}"
	}

  Before 'setup'

	Example 'Basic'
		When call "${command}"
		The line 1 of output should equal "HTTP/1.1 200 OK${SHELLSPEC_CR}"
		The entire output should end with "W3m-control: MENU Main${newline}"
	End

	Example 'Image'
		When call env 'W3M_CURRENT_IMG=http://www.example.com/' "${command}"
		The line 1 of output should equal "HTTP/1.1 200 OK${SHELLSPEC_CR}"
		The entire output should end with "W3m-control: MENU ContextMenuImage${newline}"
	End

	Example 'Link'
		When call env 'W3M_CURRENT_LINK=http://www.example.com/' "${command}"
		The line 1 of output should equal "HTTP/1.1 200 OK${SHELLSPEC_CR}"
		The entire output should end with "W3m-control: MENU ContextMenuLink${newline}"
	End

	Example 'Link & Image'
		When call env 'W3M_CURRENT_LINK=http://www.example.com/' 'W3M_CURRENT_IMG=http://www.example.com/' "${command}"
		The line 1 of output should equal "HTTP/1.1 200 OK${SHELLSPEC_CR}"
		The entire output should end with "W3m-control: MENU ContextMenuLinkImage${newline}"
	End
End
