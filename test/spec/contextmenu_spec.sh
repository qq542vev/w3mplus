#!/usr/bin/env shellspec

## File: contextmenu_spec.sh
##
## Test contextmenu.
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
##   version - 1.0.1
##   date - 2020-09-12
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
	contextmenu () {
		env 'W3MPLUS_TEMPLATE_HTTP=template/http' ${@+"${@}"} "${W3MPLUS_PATH}/bin/contextmenu"
	}

	output () {
		%text:expand
		#|HTTP/1.1 200 OK${SHELLSPEC_CR}
		#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
		#|W3m-control: BACK${SHELLSPEC_CR}
		#|W3m-control: MENU ${1}${SHELLSPEC_CR}
		#|${SHELLSPEC_CR}
	}

	Parameters
		'Basic' '' '' 'Main'
		'Link' 'http://www.example.com/' '' 'ContextMenuLink'
		'Image' '' 'http://www.example.com/test.jpg' 'ContextMenuImage'
		'Link & Image' 'http://www.example.com/' 'http://www.example.com/test.jpg' 'ContextMenuLinkImage'
	End

	Example "Test ${1} Context Menu"
		When call contextmenu "W3M_CURRENT_LINK=${2}" "W3M_CURRENT_IMG=${3}"
		The output should equal "$(output "${4}")"
	End
End
