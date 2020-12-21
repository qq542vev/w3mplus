#!/usr/bin/env shellspec

## File: closetab_spec.sh
##
## Test closetab.
##
## Usage:
##
##   (start code)
##   shellspec closetab_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-12-22
##   since - 2020-12-18
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test closetab'
	setup () {
		originalFile=$(mktemp)
		configFile=$(mktemp)

		cat <<-'EOF' >"${originalFile}"
			http://www.example.com/page3	1	1	946857600
			http://www.example.com/page2	1	1	946771200
			http://www.example.com/page1	1	1	946684800
		EOF

		cat -- "${originalFile}" >"${configFile}"
	}

	cleanup () {
		rm -f -- "${orignalFile}" "${configFile}"
	}

	Before 'setup'
	After 'cleanup'

	closetab () {
		"${W3MPLUS_PATH}/bin/closetab" --config "${configFile}" ${@+"${@}"}
	}

	Example 'Test: no argument'
		output () {
			cat -- "${originalFile}"
		}

		When call closetab
		The output should equal ''
		The status should equal '0'
		The contents of file "${configFile}" should equal "$(output)"
	End

	Example 'Test: one argument'
		output () {
			cat - -- "${originalFile}" <<-'EOF'
				http://www.example.com/page4	35	12	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
			EOF
		}

		When call closetab --line '35' --colmun '12' 'http://www.example.com/page4'
		The output should equal ''
		The status should equal '0'
		The contents of file "${configFile}" should match pattern "$(output)"
	End

	Example 'Test: multiple arguments'
		output () {
			cat - -- "${originalFile}" <<-'EOF'
				http://www.example.com/page7	-10	-6	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
				http://www.example.com/page6	0	0	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
				http://www.example.com/page5	21	12	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
				http://www.example.com/page4	35	12	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
			EOF
		}

		When call closetab --line '35' --colmun '12' 'http://www.example.com/page4' --line '21' 'http://www.example.com/page5' --line '0' --colmun '0' 'http://www.example.com/page6' --line '-10' --colmun '-6' 'http://www.example.com/page7'
		The output should equal ''
		The status should equal '0'
		The contents of file "${configFile}" should match pattern "$(output)"
	End

	Example 'Test: standard input'
		output () {
			cat - -- "${originalFile}" <<-'EOF'
				http://www.example.com/page7	5	1	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
				http://www.example.com/page6	5	1	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
				http://www.example.com/page5	5	1	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
				http://www.example.com/page4	1	1	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
			EOF
		}

		Data
			#|http://www.example.com/page5
			#|http://www.example.com/page6
		End

		When call closetab 'http://www.example.com/page4' --line '5' - 'http://www.example.com/page7'
		The output should equal ''
		The status should equal '0'
		The contents of file "${configFile}" should match pattern "$(output)"
	End

	Example 'Test: marge line'
		output () {
			cat <<-'EOF'
				http://www.example.com/page3	1	1	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
				http://www.example.com/page4	1	1	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
				http://www.example.com/page3	1	1	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
			EOF

			tail -n '+2' -- "${originalFile}"
		}

		When call closetab 'http://www.example.com/page3' 'http://www.example.com/page3' 'http://www.example.com/page4' 'http://www.example.com/page3'
		The output should equal ''
		The status should equal '0'
		The contents of file "${configFile}" should match pattern "$(output)"
	End

	Example 'Test: --size option'
		output () {
			cat <<-'EOF'
				http://www.example.com/page4	1	1	[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
			EOF

			head -n '2' -- "${originalFile}"
		}

		When call closetab --size '3' 'http://www.example.com/page4'
		The output should equal ''
		The status should equal '0'
		The contents of file "${configFile}" should match pattern "$(output)"
	End
End
