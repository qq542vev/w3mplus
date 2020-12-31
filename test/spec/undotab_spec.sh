#!/usr/bin/env shellspec

## File: undotab_spec.sh
##
## Test undotab.
##
## Usage:
##
##   (start code)
##   shellspec undotab_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2021-01-01
##   since - 2020-11-28
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test undotab'
	setup () {
		originalFile=$(mktemp)
		configFile=$(mktemp)
		unixtime=$(date -u '+%Y%m%d%H%M%S' | TZ='UTC+0' utconv)

		cat <<-EOF >"${originalFile}"
			http://www.example.com/page4	1	1	$((unixtime))
			http://www.example.com/page3	1	1	$((unixtime - 20))
			http://www.example.com/page2	1	1	$((unixtime - 40))
			http://www.example.com/page1	1	1	$((unixtime - 60))
		EOF

		cat -- "${originalFile}" >"${configFile}"

		export 'W3MPLUS_UNDO_TIMEOUT=120'
	}

	cleanup () {
		rm -f -- "${originalFile}" "${configFile}"
	}

	Before 'setup'
	After 'cleanup'

	undotab () {
		"${W3MPLUS_PATH}/bin/undotab" --config "${configFile}" ${1:+--number "${1}"} ${2:+--count "${2}"}
	}

	stdout () {
		eval "${1}" -- "${originalFile}"
	}

	output () {
		eval "${1}" -- "${originalFile}"
	}

	Describe 'Line number & Count'
		Parameters
			'' '' 'head -n 1' 'tail -n +2'
			'+1' '+1' 'head -n 1' 'tail -n +2'
			'+1' '+3' 'head -n 3' 'tail -n +4'
			'+1' '+10' 'head -n 10' 'tail -n +11'
			'+1' '+0' 'head -n -0' 'head -n 0'
			'+1' '-1' 'head -n 0' 'tail -n +1'
			'+1' '-0' 'head -n 0' 'tail -n +1'
			'-1' '-1' 'tail -n 1' 'head -n -1'
			'-1' '-3' 'tail -n 3' 'head -n -3'
			'-1' '-10' 'tail -n 10' 'head -n -10'
			'-1' '+1' 'tail -n 0' 'head -n -0'
			'-1' '+0' 'tail -n 0' 'head -n -0'
			'+2' '+2' 'sed -n -e 2,3p' 'sed -e 2,3d'
			'+3' '-2' 'sed -n -e 1,2p' 'sed -e 1,2d'
			'+3' '+0' 'sed -n -e 3,\$p' 'sed -e 3,\$d'
			'+3' '-0' 'sed -n -e 1,2p' 'sed -e 1,2d'
			'-4' '+2' 'sed -n -e 2,3p' 'sed -e 2,3d'
			'-2' '-2' 'sed -n -e 2,3p' 'sed -e 2,3d'
		End

		Example "Test: ${1:+--number ${1}} ${2:+--count ${2}}"
			When call undotab "${1}" "${2}"
			The output should equal "$(stdout "${3}")"
			The contents of file "${configFile}" should equal "$(output "${4}")"
		End
	End

	Describe 'UNIX time & UNIX time'
		Parameters
			'0' '0' 'head -n 1' 'tail -n +2'
			'+10' '0' 'head -n 1' 'tail -n +2'
			'+10' '+5' 'head -n 0' 'tail -n +1'
			'0' '-40' 'head -n 3' 'tail -n +4'
			'-21' '-200' 'tail -n +3' 'head -n 2'
			'-20' '-39' 'sed -n -e 2p' 'sed -e 2d'
			'-200' '-400' 'tail -n 0' 'head -n -0'
		End

		Example "Test: --number @$((unixtime + ${1})) --count @$((unixtime + ${2}))"
			When call undotab "@$((unixtime + ${1}))" "@$((unixtime + ${2}))"
			The output should equal "$(stdout "${3}")"
			The contents of file "${configFile}" should equal "$(output "${4}")"
		End
	End

	Describe 'UNIX time & Seconds'
		Parameters
			'-20' '+0' 'sed -n -e 2p' 'sed -e 2d'
			'-20' '-0' 'sed -n -e 2p' 'sed -e 2d'
			'-21' '+5' 'sed -n -e 2p' 'sed -e 2d'
			'-21' '-19' 'sed -n -e 3p' 'sed -e 3d'
			'-21' '-39' 'sed -n -e 3,4p' 'sed -e 3,4d'
		End

		Example "Test: --number @$((unixtime + ${1})) --count @${2}"
			When call undotab "@$((unixtime + ${1}))" "@${2}"
			The output should equal "$(stdout "${3}")"
			The contents of file "${configFile}" should equal "$(output "${4}")"
		End
	End

	Describe 'UNIX time & Count'
		Parameters
			'-20' '+1' 'sed -n -e 2p' 'sed -e 2d'
			'-20' '+2' 'sed -n -e 2,3p' 'sed -e 2,3d'
			'-20' '+0' 'sed -n -e 2,\$p' 'sed -e 2,\$d'
			'-40' '-1' 'sed -n -e 2p' 'sed -e 2d'
			'-40' '-0' 'sed -n -e 1,2p' 'sed -e 1,2d'
		End

		Example "Test: --number @$((unixtime + ${1})) --count ${2}"
			When call undotab "@$((unixtime + ${1}))" "${2}"
			The output should equal "$(stdout "${3}")"
			The contents of file "${configFile}" should equal "$(output "${4}")"
		End
	End
End
