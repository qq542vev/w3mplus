#!/usr/bin/env shellspec

## File: htmlescape_spec.sh
##
## Test htmlescape.
##
## Usage:
##
##   (start code)
##   shellspec htmlescape_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-06-13
##   since - 2020-06-13
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test htmlescape'
	setup() {
env
		command='../../.w3m/w3mplus/bin/htmlescape'
	}

  Before 'setup'

	Data
		#|&'"<>
	End

	Example 'Basic HTML Escape'
		When call "${command}"
		The output should equal '&amp;&#x27;&quot;&lt;&gt;'
	End
End
