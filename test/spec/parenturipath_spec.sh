#!/usr/bin/env shellspec

## File: parenturipath_spec.sh
##
## Test parenturipath.
##
## Usage:
##
##   (start code)
##   shellspec parenturipath_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-07-14
##   since - 2020-06-11
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test parenturipath'
	parenturipath () {
		'../../.w3m/w3mplus/bin/parenturipath' ${@+"${@}"}
	}

	Data 'http://www.example.com/a/b/c/'

	Example 'URI'
		When call parenturipath -
		The output should equal 'http://www.example.com/a/b/'
	End

	Data 'http://www.example.com/a/b/c/d'

	Example 'URI'
		When call parenturipath -
		The output should equal 'http://www.example.com/a/b/c/'
	End

	Example '2 up'
		When call parenturipath --number 2 -
		The output should equal 'http://www.example.com/a/b/'
	End

	Example '5 up'
		When call parenturipath --number 5 -
		The output should equal 'http://www.example.com/'
	End

	Data 'file:a/b/c'

	Example '2 up'
		When call parenturipath --number 2 -
		The output should equal 'file:a/'
	End

	Example '5 up'
		When call parenturipath --number 5 -
		The output should equal 'file:a/'
	End

	Data
		#|http://www.example.com/a/b/c/
		#|file:a/b/c/e/f/g
	End

	Example '4 up'
		When call parenturipath --number 4 -
		The line 1 of output should equal 'http://www.example.com/'
		The line 2 of output should equal 'file:a/b/'
	End
End
