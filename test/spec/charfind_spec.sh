#!/usr/bin/env shellspec

## File: charfind_spec.sh
##
## Test charfind.
##
## Usage:
##
##   (start code)
##   shellspec charfind_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-08-10
##   since - 2020-08-07
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test charfind'
	charfind () {
		env "W3MPLUS_TEMPLATE_HTTP=${SHELLSPEC_PROJECT_ROOT}/template/http" '../../.w3m/w3mplus/bin/charfind' ${@+"${@}"}
	}

	output () {
		cat <<- EOF
			HTTP/1.1 200 OK${SHELLSPEC_CR}
			Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			W3m-control: BACK${SHELLSPEC_CR}
		EOF

		for field in ${@+"${@}"}; do
			printf '%s\r\n' "${field}"
		done

		printf '\r\n'
	}

	Example 'Test: single argument'
		When call charfind -- 'arg'
		The output should equal "$(output 'W3m-control: SEARCH arg')"
	End

	Example 'Test: multiple argument'
		When call charfind -- 'arg1' 'arg2' 'arg3'
		The output should equal "$(output 'W3m-control: SEARCH arg1|arg2|arg3')"
	End

	Example 'Test: regular expression characters'
		When call charfind -- '*' '+' '[]' '()' '|' '\'
		The output should equal "$(output 'W3m-control: SEARCH \*|\+|\[\]|\(\)|\||\\')"
	End

	Example 'Test: standard input'
		Data 'arg1 arg2'

		When call charfind - -- 'arg3'
		The output should equal "$(output 'W3m-control: SEARCH arg1 arg2|arg3')"
	End

	Example 'Test: --exact option'
		When call charfind --exact -- 'arg1' 'arg2'
		The output should equal "$(output 'W3m-control: SEARCH (^|[	 ])(arg1|arg2)([	 ]|$)' 'W3m-control: MOVE_RIGHT1')"
	End
End
