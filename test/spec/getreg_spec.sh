#!/usr/bin/env shellspec

## File: getreg_spec.sh
##
## Test getreg.
##
## Usage:
##
##   (start code)
##   shellspec getreg_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-07-15
##   since - 2020-07-15
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test getreg'
	setup () {
		config="${SHELLSPEC_PROJECT_ROOT}/config/register"
	}

	Before 'setup'

	getreg () {
		'../../.w3m/w3mplus/bin/getreg' --config "${config}" ${@+"${@}"}
	}

	Example 'Test no argument'
		output () {
			cat -- "${config}"
		}

		When call getreg
		The output should equal "$(output)"
	End

	Example 'Test key 0'
		output () {
			awk -F '\t' -v 'key=0' -- '$1 == key { printf("%s", $2); }' "${config}"
		}

		When call getreg '0'
		The output should equal "$(output)"
	End

	Example 'Test key /'
		output () {
			awk -F '\t' -v 'key=/' -- '$1 == key { printf("%s", $2); }' "${config}"
		}

		When call getreg '/'
		The output should equal "$(output)"
	End

	Example 'Test key a 2'
		output () {
			awk -F '\t' -v 'key=a' -- '$1 == key { printf("%s\n", $0); }' "${config}"
			awk -F '\t' -v 'key=2' -- '$1 == key { printf("%s\n", $0); }' "${config}"
		}

		When call getreg --row 'a' '2'
		The output should equal "$(output)"
	End

	Example 'Test key z A'
		output () {
			awk -F '\t' -v 'key=A' -- '$1 == key { printf("%s\n", $0); }' "${config}"
		}

		When call getreg --row 'z' 'A'
		The output should equal "$(output)"
		The status should equal '1'
	End
End
