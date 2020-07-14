#!/usr/bin/env shellspec

## File: redirect_spec.sh
##
## Test redirect.
##
## Usage:
##
##   (start code)
##   shellspec redirect_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-07-15
##   since - 2020-07-06
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test printhtml'
	setup () {
		newline="${SHELLSPEC_CR}${SHELLSPEC_LF}"
	}

  Before 'setup'

	redirect () {
		env ${@+"${@}"} '../../.w3m/w3mplus/bin/redirect' --http-template "${SHELLSPEC_PROJECT_ROOT}/template/http" -
	}

	Data
		#|http://www.example.com/page/1
		#|W3m-control: DOWN
		#|http://www.example.com/page/2
		#|W3m-control: DOWN
	End

	Example 'Test no argument'
		output () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|W3m-control: BACK${SHELLSPEC_CR}
			#|W3m-control: GOTO http://www.example.com/page/1${SHELLSPEC_CR}
			#|W3m-control: DOWN${SHELLSPEC_CR}
			#|W3m-control: TAB_GOTO http://www.example.com/page/2${SHELLSPEC_CR}
			#|W3m-control: DOWN${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
		}

		When call redirect
		The output should equal "$(output)"
	End

	Example 'Test W3MPLUS_REDIRECT_TYPE=1'
		output () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|W3m-control: BACK${SHELLSPEC_CR}
			#|W3m-control: TAB_GOTO http://www.example.com/page/1${SHELLSPEC_CR}
			#|W3m-control: DOWN${SHELLSPEC_CR}
			#|W3m-control: TAB_GOTO http://www.example.com/page/2${SHELLSPEC_CR}
			#|W3m-control: DOWN${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
		}

		When call redirect 'W3MPLUS_REDIRECT_TYPE=1'
		The output should equal "$(output)"
	End

	Example 'Test W3MPLUS_REDIRECT_TYPE=2'
		output () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|W3m-control: BACK${SHELLSPEC_CR}
			#|W3m-control: NEW_TAB${SHELLSPEC_CR}
			#|W3m-control: GOTO http://www.example.com/page/1${SHELLSPEC_CR}
			#|W3m-control: DELETE_PREVBUF${SHELLSPEC_CR}
			#|W3m-control: DOWN${SHELLSPEC_CR}
			#|W3m-control: TAB_GOTO http://www.example.com/page/2${SHELLSPEC_CR}
			#|W3m-control: DOWN${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
		}

		When call redirect 'W3MPLUS_REDIRECT_TYPE=2'
		The output should equal "$(output)"
	End

	Example 'Test W3MPLUS_REDIRECT_TYPE=3'
		output () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|W3m-control: GOTO http://www.example.com/page/1${SHELLSPEC_CR}
			#|W3m-control: DELETE_PREVBUF${SHELLSPEC_CR}
			#|W3m-control: DOWN${SHELLSPEC_CR}
			#|W3m-control: TAB_GOTO http://www.example.com/page/2${SHELLSPEC_CR}
			#|W3m-control: DOWN${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
		}

		When call redirect 'W3MPLUS_REDIRECT_TYPE=3'
		The output should equal "$(output)"
	End
End
