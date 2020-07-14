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
##   date - 2020-07-14
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
	incrementuri () {
		'../../.w3m/w3mplus/bin/incrementuri' ${@+"${@}"}
	}

	Data
		#|http://www.example.com/123
		#|http://www.example.com/123?key=456
		#|http://www.example.com/123?key=456#789
	End

	Example 'Basic increment'
		When call incrementuri -
		The line 1 of output should equal 'http://www.example.com/124'
		The line 2 of output should equal 'http://www.example.com/123?key=457'
		The line 3 of output should equal 'http://www.example.com/123?key=456#790'
	End

	Example 'Test --number option (increment)'
		When call incrementuri --number '+300' -
		The line 1 of output should equal 'http://www.example.com/423'
		The line 2 of output should equal 'http://www.example.com/123?key=756'
		The line 3 of output should equal 'http://www.example.com/123?key=456#1089'
	End

	Example 'Test --number option (decrement)'
		When call incrementuri --number '-300' -
		The line 1 of output should equal 'http://www.example.com/0'
		The line 2 of output should equal 'http://www.example.com/123?key=156'
		The line 3 of output should equal 'http://www.example.com/123?key=456#489'
	End

	Example 'Test --number option (specify)'
		When call incrementuri --number '300' -
		The line 1 of output should equal 'http://www.example.com/300'
		The line 2 of output should equal 'http://www.example.com/123?key=300'
		The line 3 of output should equal 'http://www.example.com/123?key=456#300'
	End

	Example 'Test --position option'
		When call incrementuri --position '+2' --number '50' -
		The line 1 of output should equal 'http://www.example.com/123'
		The line 2 of output should equal 'http://www.example.com/123?key=50'
		The line 3 of output should equal 'http://www.example.com/123?key=50#789'
	End

	Example 'Test --position option'
		When call incrementuri --position '-2' --number '50' -
		The line 1 of output should equal 'http://www.example.com/123'
		The line 2 of output should equal 'http://www.example.com/50?key=456'
		The line 3 of output should equal 'http://www.example.com/123?key=50#789'
	End
End
