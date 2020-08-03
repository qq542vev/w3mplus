#!/usr/bin/env shellspec

## File: getautocmd_spec.sh
##
## Test getautocmd.
##
## Usage:
##
##   (start code)
##   shellspec getautocmd_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-08-04
##   since - 2020-07-19
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test getautocmd'
	setup () {
		config="${SHELLSPEC_PROJECT_ROOT}/config/autocommand"
	}

	Before setup

	getautocmd () {
	'../../.w3m/w3mplus/bin/getautocmd' --config "${config}" -- ${@+"${@}"}
	}

	Example 'Test a1'
		When call getautocmd 'a' 'https://www.example.com/a1'
		The output should equal 'a1'
	End

	Example 'Test a2'
		When call getautocmd 'a' 'https://www.example.com/a2'
		The output should equal 'a2'
	End

	Example 'Test a1 b1'
		When call getautocmd 'a' 'https://www.example.com/a1' 'b' 'https://www.example.com/b1'
		The output should equal "$(printf 'a1\nb1')"
	End

	Example 'Test c'
		When call getautocmd 'c' 'https://www.example.com/c1'
		The output should equal ''
	End

	Example 'Test a3'
		When call getautocmd 'a' 'https://www.example.com/a3'
		The output should equal ''
	End
End
