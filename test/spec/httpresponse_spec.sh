#!/usr/bin/env shellspec

## File: httpresponse_spec.sh
##
## Test httpresponse.
##
## Usage:
##
##   (start code)
##   shellspec httpresponse_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-07-14
##   since - 2020-06-11
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test httpresponse'
	httpresponse () {
		'../../.w3m/w3mplus/bin/httpresponse' --http-template "${SHELLSPEC_PROJECT_ROOT}/template/http" ${@+"${@}"}
	}

	Data
		#|Content-Type: text/plain; charset=UTF-8
		#|Server: ShellSpec
	End

	Example 'Basic'
		output () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|W3m-control: BACK${SHELLSPEC_CR}
			#|Content-Type: text/plain; charset=UTF-8${SHELLSPEC_CR}
			#|Server: ShellSpec${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
		}

		When call httpresponse -
		The output should equal "$(output)"
	End

	Example 'Test --status-code option'
		output () {
			%text:expand
			#|HTTP/1.1 404 Not Found${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|W3m-control: BACK${SHELLSPEC_CR}
			#|Content-Type: text/plain; charset=UTF-8${SHELLSPEC_CR}
			#|Server: ShellSpec${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
		}

		When call httpresponse --status-code '404 Not Found' -
		The output should equal "$(output)"
	End
End
