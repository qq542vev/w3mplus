#!/usr/bin/env shellspec

## File: mvpara_spec.sh
##
## Test mvpara.
##
## Usage:
##
##   (start code)
##   shellspec mvpara_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-08-11
##   since - 2020-08-11
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test mvpara'
	mvpara () {
		env "W3MPLUS_TEMPLATE_HTTP=${SHELLSPEC_PROJECT_ROOT}/template/http" '../../.w3m/w3mplus/bin/mvpara' ${@+"${@}"}
	}

	output () {
		cat <<- EOF
			HTTP/1.1 200 OK${SHELLSPEC_CR}
			Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			W3m-control: BACK${SHELLSPEC_CR}
			W3m-control: GOTO_LINE ${1}${SHELLSPEC_CR}
			W3m-control: MOVE_RIGHT1 ${2-0}${SHELLSPEC_CR}
			${SHELLSPEC_CR}
		EOF
	}

	Data
		#|
		#|Line 2
		#|
		#|  Line 4
		#|  Line 5
		#|
		#|Line 7
		#|Line 8
		#|
		#|Line 10
		#|
	End

	Example 'Test: Line 1, Number +1'
		When call mvpara -
		The output should equal "$(output '2')"
	End

	Example 'Test: Line 2, Number +1'
		When call mvpara --line '2' -
		The output should equal "$(output '4' '2')"
	End

	Example 'Test: Line 10, Number +1'
		When call mvpara --line '10' -
		The output should equal "$(output '11')"
	End

	Example 'Test: Line 11, Number +1'
		When call mvpara --line '11' -
		The output should equal "$(output '11')"
	End

	Example 'Test: Line 11, Number -1'
		When call mvpara --line '11' --number '-1' -
		The output should equal "$(output '10')"
	End

	Example 'Test: Line 10, Number -2'
		When call mvpara --line '10' --number '-2' -
		The output should equal "$(output '4' '2')"
	End

	Example 'Test: Line 2, Number -1'
		When call mvpara --line '2' --number '-1' -
		The output should equal "$(output '1')"
	End
End
