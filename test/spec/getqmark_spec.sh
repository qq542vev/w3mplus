#!/usr/bin/env shellspec

## File: getqmark_spec.sh
##
## Test getqmark.
##
## Usage:
##
##   (start code)
##   shellspec getqmark_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-07-12
##   since - 2020-07-09
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test getqmark'
	getqmark () {
		'../../.w3m/w3mplus/bin/getqmark' --config "${SHELLSPEC_PROJECT_ROOT}/config/quickmark" ${@+"${@}"}
	}

	Example 'Test no argument'
		output () {
			cat -- "${SHELLSPEC_PROJECT_ROOT}/config/quickmark"
		}

		When call getqmark
		The output should equal "$(output)"
	End

	Example 'Test: a'
		output () {
			grep -e '^a' -- "${SHELLSPEC_PROJECT_ROOT}/config/quickmark"
		}

		When call getqmark 'a'
		The output should equal "$(output)"
	End

	Example 'Test: b c'
		output () {
			grep -e '^b' -e '^c' -- "${SHELLSPEC_PROJECT_ROOT}/config/quickmark"
		}

		When call getqmark 'b' 'c'
		The output should equal "$(output)"
	End

	Example 'Test: b a a c'
		output () {
			grep -e '^b' -- "${SHELLSPEC_PROJECT_ROOT}/config/quickmark"
			grep -e '^a' -- "${SHELLSPEC_PROJECT_ROOT}/config/quickmark"
			grep -e '^a' -e '^c' -- "${SHELLSPEC_PROJECT_ROOT}/config/quickmark"
		}

		Data 'b' 'a'

		When call getqmark - 'a' 'c'
		The output should equal "$(output)"
	End

	Example 'Test: d'
		output () {
			grep -e '^d' -- "${SHELLSPEC_PROJECT_ROOT}/config/quickmark"
		}

		When call getqmark 'd'
		The output should equal "$(output)"
	End

	Example 'Test: z'
		When call getqmark 'z'
		The output should equal ''
		The status should equal '1'
	End

	Example 'Test: z a'
		output () {
			grep -e '^a' -- "${SHELLSPEC_PROJECT_ROOT}/config/quickmark"
		}

		When call getqmark 'z' 'a'
		The output should equal "$(output)"
		The status should equal '1'
	End

	Example 'Test: -'
		output () {
			grep -e '^-' -- "${SHELLSPEC_PROJECT_ROOT}/config/quickmark"
		}

		When call getqmark -- '-'
		The output should equal "$(output)"
	End

	Example 'Test: [a-z]'
		output () {
			grep -e '^[a-z]' -- "${SHELLSPEC_PROJECT_ROOT}/config/quickmark"
		}

		When call getqmark --extended-regexp '[a-z]'
		The output should equal "$(output)"
	End
End
