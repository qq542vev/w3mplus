#!/usr/bin/env shellspec

## File: abouturi_spec.sh
##
## Test abouturi.
##
## Usage:
##
##   (start code)
##   shellsoec abouturi_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-06-11
##   since - 2019-06-11
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test abouturi'
	callcmd() {
		../../.w3m/w3mplus/bin/bmarkbar ${@+"${@}"}
	}

	Example 'No arguments'
		When call callcmd
		The line 1 of output should equal "$(printf 'HTTP/1.1 200 OK\r')"
	End

	Parameters
		'left'
		'right'
		'top'
		'bottom'
	End

	Example 'Position'
		When call callcmd --position "${1}"
		The line 1 of output should equal "$(printf 'HTTP/1.1 200 OK\r')"
	End
End
