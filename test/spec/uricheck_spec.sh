#!/usr/bin/env shellspec

## File: uricheck_spec.sh
##
## Test uricheck.
##
## Usage:
##
##   (start code)
##   shellspec uricheck_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-06-11
##   since - 2020-06-11
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test uricheck'
	setup() {
		command='../../.w3m/w3mplus/bin/uricheck'
	}

  Before 'setup'

	Data
		#|http://www.example.com/
	End

	Example 'Basic'
		When call "${command}" -
		The output should equal 'http://www.example.com/'
	End

	Example 'Inverse URI'
		When call "${command}" --invert -
		The output should equal ''
		The status should equal 1
	End

	Data
		#|http//www.example.com/
	End

	Example 'Bad URI'
		When call "${command}" -
		The output should equal ''
		The status should equal 1
	End

	Example 'Inverse URI'
		When call "${command}" --invert -
		The output should equal 'http//www.example.com/'
	End

	Data
		#|http://www.example.com/example1
		#|NotURI1
		#|http://www.example.com/example2
		#|NotURI2
	End

	Example 'Inverse URI'
		When call "${command}" -
		The line 1 of output should equal 'http://www.example.com/example1'
		The line 2 of output should equal 'http://www.example.com/example2'
		The status should equal 1
	End

	Example 'Inverse URI'
		When call "${command}" --invert -
		The line 1 of output should equal 'NotURI1'
		The line 2 of output should equal 'NotURI2'
		The status should equal 1
	End

	Data
		#|HTTP://www.EXAMPLE.com:/%2E%2E/%70%61%74%68
	End

	Example 'Normalize URI'
		When call "${command}" --normalize -
		The output should equal 'http://www.example.com/path'
	End

	Data
		#|http://userinfo@www.example.com:80/path?query#fragment
		#|mailto:user@example.com?subject=test
	End

	Example 'URI parts'
		When call "${command}" --field 'scheme,authority,userinfo,host,port,path,query,fragment' -
		The line 1 of output should equal 'http	userinfo@www.example.com:80	userinfo	www.example.com	80	/path	query	fragment'
		The line 2 of output should equal 'mailto					user@example.com	subject=test	'
	End

	Example 'URI parts'
		When call "${command}" --field 'scheme!,authority!,userinfo!,host,port!,path,query!,fragment!' -
		The line 1 of output should equal 'http:	//userinfo@www.example.com:80	userinfo@	www.example.com	:80	/path	?query	#fragment'
		The line 2 of output should equal 'mailto:					user@example.com	?subject=test	'
	End
End
