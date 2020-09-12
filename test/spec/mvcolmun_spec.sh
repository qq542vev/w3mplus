#!/usr/bin/env shellspec

## File: mvcolmun_spec.sh
##
## Test mvcolmun.
##
## Usage:
##
##   (start code)
##   shellspec mvcolmun_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.1
##   date - 2020-09-12
##   since - 2020-08-11
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test mvcolmun'
	mvcolmun () {
		"${W3MPLUS_PATH}/bin/mvcolmun" ${@+"${@}"}
	}

	Data
		#|Paragraph 1
		#|
		#|  Paragraph 2
	End

	Example 'Test: --number 0'
		When call mvcolmun -
		The output should equal '0'
	End

	Example 'Test: --number 100'
		When call mvcolmun --number '100' -
		The output should equal '10'
	End

	Example 'Test: --number 0, --skip'
		When call mvcolmun --line '3' --skip -
		The output should equal '2'
	End

	Example 'Test: --number 50'
		When call mvcolmun --line '3' --number '50' -
		The output should equal '6'
	End

	Example 'Test: --number 50'
		When call mvcolmun --line '3' --number '50' --skip -
		The output should equal '7'
	End
End
