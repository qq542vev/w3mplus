#!/usr/bin/env shellspec

## File: printhtml_spec.sh
##
## Test printhtml.
##
## Usage:
##
##   (start code)
##   shellspec printhtml_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-07-15
##   since - 2020-06-11
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test printhtml'
	setup() {
		newline="${SHELLSPEC_CR}${SHELLSPEC_LF}"
	}

  Before 'setup'

	printhtml () {
		'../../.w3m/w3mplus/bin/printhtml' --http-template "${SHELLSPEC_PROJECT_ROOT}/template/http" --html-template "${SHELLSPEC_PROJECT_ROOT}/template/html" ${@+"${@}"}
	}

	Example 'Test no argument'
		output () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|Content-Type: text/html; charset=UTF-8${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
			#|<html>
			#|<head>
			#|<title>No title</title>
			#|
			#|</head>
			#|<body></body>
			#|</html>
		}

		When call printhtml
		The output should equal "$(output)"
	End

	Example 'Test --statu-code option'
		output () {
			%text:expand
			#|HTTP/1.1 404 Not Found${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|Content-Type: text/html; charset=UTF-8${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
			#|<html>
			#|<head>
			#|<title>No title</title>
			#|
			#|</head>
			#|<body></body>
			#|</html>
		}

		When call printhtml --status-code '404 Not Found'
		The output should equal "$(output)"
	End

	Example 'Test --title option'
		output () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|Content-Type: text/html; charset=UTF-8${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
			#|<html>
			#|<head>
			#|<title>printhtml Test title</title>
			#|
			#|</head>
			#|<body></body>
			#|</html>
		}

		When call printhtml --title 'printhtml Test title'
		The output should equal "$(output)"
	End

	Example 'Test --meta-data option'
		output () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|Content-Type: text/html; charset=UTF-8${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
			#|<html>
			#|<head>
			#|<title>No title</title>
			#|<meta name="description" content="Test printhtml" />
			#|</head>
			#|<body></body>
			#|</html>
		}

		When call printhtml --meta-data '<meta name="description" content="Test printhtml" />'
		The output should equal "$(output)"
	End

	Example 'Test --header-field option'
		output () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|Content-Type: text/html; charset=UTF-8${SHELLSPEC_CR}
			#|Server: ShellSpec${SHELLSPEC_CR}
			#|X-Powered-By: ShellSpec${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
			#|<html>
			#|<head>
			#|<title>No title</title>
			#|
			#|</head>
			#|<body></body>
			#|</html>
		}

		When call printhtml --header-field 'Server: ShellSpec' --header-field 'X-Powered-By: ShellSpec'
		The output should equal "$(output)"
	End

	Example 'Test stdin'
		Data '<p>Main Contents</p>' | tr -d '\n'

		output () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Wed, 21 Oct 2015 07:28:00 GMT${SHELLSPEC_CR}
			#|Content-Type: text/html; charset=UTF-8${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
			#|<html>
			#|<head>
			#|<title>No title</title>
			#|
			#|</head>
			#|<body><p>Main Contents</p></body>
			#|</html>
		}

		When call printhtml -
		The output should equal "$(output)"
	End
End
