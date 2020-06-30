#!/usr/bin/env shellspec

## File: parsequery_spec.sh
##
## Test parsequery.
##
## Usage:
##
##   (start code)
##   shellspec parsequery_spec.sh
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

Describe 'Test parsequery'
	setup() {
		command='../../.w3m/w3mplus/bin/parsequery'
	}

  Before 'setup'

	Data
		#|key1=value1&'key2'='value2'&key3=&key4&=&
	End

	Example 'Basic parse'
		When call "${command}" -
		The output should equal "'key1' 'value1' \"'\"'key2'\"'\" \"'\"'value2'\"'\" 'key3' '' 'key4' '' '' ''"
	End
End
