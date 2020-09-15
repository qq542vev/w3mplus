#!/usr/bin/env shellspec

## File: setqmark_spec.sh
##
## Test setqmark.
##
## Usage:
##
##   (start code)
##   shellspec setqmark_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-09-16
##   since - 2020-07-09
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test setqmark'
	setup () {
		tmpFile=$(mktemp)

		printf 'a\thttp://www.exaple.com/page/1\t5\t2\t2020-07-08T00:00:00Z\n' >"${tmpFile}"
	}

	cleanup () {
		rm -f "${tmpFile}"
	}

	Before 'setup'
	After 'cleanup'

	setqmark () {
		env 'W3MPLUS_TEMPLATE_HTTP=template/http' 'W3MPLUS_TEMPLATE_HTML=template/html' "${W3MPLUS_PATH}/bin/setqmark" --config "${tmpFile}" ${@+"${@}"}
	}

	stdout () {
		template/http | sed -n -e "/^$(printf '\r')\$/{q}; p"
	}

	Example 'Test: add b key'
		output () {
			%text
			#|a	http://www.exaple.com/page/1	5	2	2020-07-08T00:00:00Z
			#|b	http://www.exaple.com/page/2	1	1	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
		}

		When call setqmark 'b' 'http://www.exaple.com/page/2'
		The output should start with "$(stdout)"
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End

	Example 'Test: add A key'
		output () {
			%text
			#|A	http://www.exaple.com/page/2	3	10	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
			#|a	http://www.exaple.com/page/1	5	2	2020-07-08T00:00:00Z
		}

		When call setqmark 'A' --line '3' --colmun '10' 'http://www.exaple.com/page/2'
		The output should start with "$(stdout)"
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End

	Example 'Test: add multiple c key'
		output () {
			%text
			#|a	http://www.exaple.com/page/1	5	2	2020-07-08T00:00:00Z
			#|c	http://www.exaple.com/page/2	3	10	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
			#|c	http://www.exaple.com/page/3	3	10	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
			#|c	http://www.exaple.com/page/4	7	4	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
		}

		When call setqmark 'c' --line '3' --colmun '10' 'http://www.exaple.com/page/2' 'http://www.exaple.com/page/3' --line '7' --colmun '4' 'http://www.exaple.com/page/4'
		The output should start with "$(stdout)"
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End

	Example 'Test: modify a key'
		output () {
			%text
			#|a	http://www.exaple.com/page/2	1	1	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
			#|a	http://www.exaple.com/page/3	1	1	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
		}

		When call setqmark 'a' 'http://www.exaple.com/page/2' 'http://www.exaple.com/page/3'
		The output should start with "$(stdout)"
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End

	Example 'Test: delete a key'
		When call setqmark 'a'
		The output should start with "$(stdout)"
		The status should equal '0'
		The contents of file "${tmpFile}" should eq ''
	End
End
