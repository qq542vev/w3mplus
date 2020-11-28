#!/usr/bin/env shellspec

## File: search_spec.sh
##
## Test search.
##
## Usage:
##
##   (start code)
##   shellspec search_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-11-28
##   since - 2020-07-09
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test search'
	setup () {
		tmpHistoryFile=$(mktemp)
		tmpConfigFile=$(mktemp)

		cat <<- 'EOF' >"${tmpHistoryFile}"
			bing%20keyword1%20keyword2	bing	2020-06-03T16:12:23Z
			google%20search	google	2020-06-03T16:12:23Z
			twitter%20search	twitter	2020-06-03T16:12:23Z
		EOF

		bingURL='https://www.bing.com/search?q={searchTerms}'
		googleURL='https://www.google.com/search?ie=UTF-8&oe=UTF-8&q={searchTerms}'
		twitterURL='https://twitter.com/search?q={searchTerms}'

		cat <<- EOF >"${tmpConfigFile}"
			bing	${bingURL}
			google	${googleURL}
			twitter	${twitterURL}
		EOF
	}

	cleanup () {
		rm -f "${tmpHistoryFile}" "${tmpConfigFile}"
	}

	Before 'setup'
	After 'cleanup'

	search () {
		tr -d '\n' | "${W3MPLUS_PATH}/bin/search" --config "${tmpConfigFile}" --history "${tmpHistoryFile}" ${@+"${@}"}
	}

	Describe 'Success'
		Parameters
			# name keyword engine decoded
			'Bing' 'test search' 'bing' 'test%20search'
			'Google' 'test search' 'google' 'test%20search'
			'History Last Search' '!!' 'google' 'twitter%20search'
			'History First Search' '!1' 'google' 'bing%20keyword1%20keyword2'
			'History !-2' '!-2' 'google' 'google%20search'
			'History !goo' '!goo' 'google' 'google%20search'
			'History !?wit?' '!?wit?' 'twitter' 'twitter%20search'
			'History !1:0' '!1:0' 'bing' 'bing'
			'History !1:$' '!1:$' 'bing' 'keyword2'
			'History !1:0-1' '!1:0-1' 'bing' 'bing%20keyword1'
			'History !1:0-$' '!1:0-$' 'bing' 'bing%20keyword1%20keyword2'
			'History !1:0-' '!1:0-' 'bing' 'bing%20keyword1'
			'History !1:-8' '!1:-8' 'bing' 'bing%20keyword1%20keyword2'
			'History !1:*' '!1:*' 'bing' 'keyword1%20keyword2'
		End

		Example "Test: ${1}"
			stdout () {
				awk -F '\t' -v "engine=${1}" -- '$1 == engine { print($2) }' "${tmpConfigFile}" | sed -e "s/{searchTerms}/${2}/g"
			}

			output () {
				%text:expand
				#|${1}	${2}	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
			}

			Data "${2}"

			When call search --engine "${3}"
			The output should equal "$(stdout "${3}" "${4}")"
			The lines of the contents of file "${tmpHistoryFile}" should eq 4
			The line 4 of the contents of file "${tmpHistoryFile}" should match pattern "$(output "${4}" "${3}")"
		End
	End

	Describe 'Empty'
		Parameters
			# name keyword engine decoded
			'Empty' ''
			'Empty' '!!:4'
			'Empty' '!!:1-'
			'Empty' '!!:4-$'
		End

		Example "Test: ${1}"
			stdout () {
				awk -F '\t' -v "engine=${1}" -- '$1 == engine { print($2) }' "${tmpConfigFile}" | sed -e 's/{searchTerms}//g'
			}

			Data "${2}"

			When call search --engine 'bing'
			The output should equal "$(stdout 'bing')"
			The lines of the contents of file "${tmpHistoryFile}" should eq 3
		End
	End

	Describe 'Error'
		Parameters
			# name keyword
			'Over !4' '!4'
			'Over !-4' '!-4'
			'None !error' '!error'
			'None !?err?' '!?err?'
		End

		Example 'Test: ${1}'
			Data "${2}"

			When call search --engine google
			The output should match pattern 'data:*'
			The lines of the contents of file "${tmpHistoryFile}" should eq 3
		End
	End
End
