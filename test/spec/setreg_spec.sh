#!/usr/bin/env shellspec

## File: setreg_spec.sh
##
## Test setreg.
##
## Usage:
##
##   (start code)
##   shellspec setreg_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-09-17
##   since - 2020-09-16
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test setreg'
	setup () {
		tmpFile=$(mktemp)

		cat <<- 'EOF' >"${tmpFile}"
			0	Number register\n	2020-01-01T00:00:00Z
			x	Name register\n	2020-01-01T00:00:00Z
		EOF
	}

	cleanup () {
		rm -f "${tmpFile}"
	}

	Before 'setup'
	After 'cleanup'

	setreg () {
		"${W3MPLUS_PATH}/bin/setreg" --config "${tmpFile}" ${@+"${@}"}
	}

	Data
		#|New register
	End

	Example 'Test: add number register'
		output () {
			%text
			#|0	New register\n	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
			#|1	Number register\n	2020-01-01T00:00:00Z
			#|x	Name register\n	2020-01-01T00:00:00Z
		}

		When call setreg '+' -
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End

	Example 'Test: add name register'
		output () {
			%text
			#|0	Number register\n	2020-01-01T00:00:00Z
			#|a	New register\n	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
			#|x	Name register\n	2020-01-01T00:00:00Z
		}

		When call setreg 'a' -
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End

	Example 'Test: modify name register'
		output () {
			%text
			#|0	Number register\n	2020-01-01T00:00:00Z
			#|x	New register\n	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
		}

		When call setreg 'x' -
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End

	Example 'Test: append name register'
		output () {
			%text
			#|0	Number register\n	2020-01-01T00:00:00Z
			#|x	Name register\nNew register\n	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
		}

		When call setreg '+x' -
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End

	Example 'Test: delete number register'
		output () {
			%text
			#|x	Name register\n	2020-01-01T00:00:00Z
		}

		When call setreg '+' ''
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End

	Example 'Test: delete name register'
		output () {
			%text
			#|0	Number register\n	2020-01-01T00:00:00Z
		}

		When call setreg 'x' ''
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End
End
