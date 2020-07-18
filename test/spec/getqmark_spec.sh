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
	setup () {
		config="${SHELLSPEC_PROJECT_ROOT}/config/quickmark"
	}

	Before 'setup'

	getqmark () {
		'../../.w3m/w3mplus/bin/getqmark' --config "${config}" ${@+"${@}"}
	}

	Example 'Test no argument'
		output () {
			cat -- "${config}"
		}

		When call getqmark
		The output should equal "$(output)"
	End

	Example 'Test: a'
		output () {
			grep -e '^a' -- "${config}"
		}

		When call getqmark 'a'
		The output should equal "$(output)"
	End

	Example 'Test: b c'
		output () {
			grep -e '^b' -e '^c' -- "${config}"
		}

		When call getqmark 'b' 'c'
		The output should equal "$(output)"
	End

	Example 'Test: b a a c'
		output () {
			grep -e '^b' -- "${config}"
			grep -e '^a' -- "${config}"
			grep -e '^a' -e '^c' -- "${config}"
		}

		Data 'b' 'a'

		When call getqmark - 'a' 'c'
		The output should equal "$(output)"
	End

	Example 'Test: d'
		output () {
			grep -e '^d' -- "${config}"
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
			grep -e '^a' -- "${config}"
		}

		When call getqmark 'z' 'a'
		The output should equal "$(output)"
		The status should equal '1'
	End

	Example 'Test: -'
		output () {
			grep -e '^-' -- "${config}"
		}

		When call getqmark -- '-'
		The output should equal "$(output)"
	End

	Example 'Test: [a-z]'
		output () {
			grep -e '^[a-z]' -- "${config}"
		}

		When call getqmark --extended-regexp '[a-z]'
		The output should equal "$(output)"
	End
End
