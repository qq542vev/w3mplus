#!/usr/bin/env shellspec

## File: parsequery_spec.sh
##
## Test parsequery.
##
## Usage:
##
##   (start code)
##   shellspec parsequery_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.1
##   date - 2020-09-12
##   since - 2020-06-13
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test parsequery'
	parsequery () {
		"${W3MPLUS_PATH}/bin/parsequery" ${@+"${@}"}
	}

	Data
		#|key1=value1&'key2'='value2'&key3=&key4&=&
	End

	Example 'Basic parse'
		When call parsequery -
		The output should equal "'key1' 'value1' \"'\"'key2'\"'\" \"'\"'value2'\"'\" 'key3' '' 'key4' '' '' ''"
	End

	Example 'Test prefix & suffix'
		output () {
			%text
			#|pre_key1_suf='value1'
			#|pre_key3_suf=''
			#|pre_key4_suf=''
		}

		When call parsequery --prefix 'pre_' --suffix '_suf' -
		The output should equal "$(output)"
	End

	Example 'Test name encode'
		output () {
			%text
			#|key1='value1'
			#|_27key2_27="'"'value2'"'"
			#|key3=''
			#|key4=''
			#|=''
		}

		When call parsequery --encode -
		The output should equal "$(output)"
	End

	Example 'Test name encode + prefix'
		output () {
			%text
			#|prefix_key1='value1'
			#|prefix__27key2_27="'"'value2'"'"
			#|prefix_key3=''
			#|prefix_key4=''
			#|prefix_=''
		}

		When call parsequery --prefix 'prefix_' --encode -
		The output should equal "$(output)"
	End
End
