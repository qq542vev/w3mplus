#!/usr/bin/env shellspec

## File: incrementuri_spec.sh
##
## Test incrementuri.
##
## Usage:
##
##   (start code)
##   shellspec incrementuri_spec.sh
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

Describe 'Test incrementuri'
	setup() {
		command='../../.w3m/w3mplus/bin/incrementuri'
	}

  Before 'setup'

	Data
		#|http://www.example.com/123
		#|http://www.example.com/123?key=456
		#|http://www.example.com/123?key=456#789
	End

	Example 'Basic increment'
		When call "${command}" -
		The line 1 of output should equal 'http://www.example.com/124'
		The line 2 of output should equal 'http://www.example.com/123?key=457'
		The line 3 of output should equal 'http://www.example.com/123?key=456#790'
	End

	Example 'Increment +300'
		When call "${command}" --number '+300' -
		The line 1 of output should equal 'http://www.example.com/423'
		The line 2 of output should equal 'http://www.example.com/123?key=756'
		The line 3 of output should equal 'http://www.example.com/123?key=456#1089'
	End

	Example 'Decrement -300'
		When call "${command}" --number '-300' -
		The line 1 of output should equal 'http://www.example.com/0'
		The line 2 of output should equal 'http://www.example.com/123?key=156'
		The line 3 of output should equal 'http://www.example.com/123?key=456#489'
	End

	Example 'Specify 300'
		When call "${command}" --number '300' -
		The line 1 of output should equal 'http://www.example.com/300'
		The line 2 of output should equal 'http://www.example.com/123?key=300'
		The line 3 of output should equal 'http://www.example.com/123?key=456#300'
	End
End
