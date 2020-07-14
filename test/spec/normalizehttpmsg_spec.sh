#!/usr/bin/env shellspec

## File: normalizehttpmsg_spec.sh
##
## Test normalizehttpmsg.
##
## Usage:
##
##   (start code)
##   shellspec normalizehttpmsg_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-07-15
##   since - 2020-06-28
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test normalizehttpmsg'
	normalizehttpmsg () {
		'../../.w3m/w3mplus/bin/normalizehttpmsg' ${@+"${@}"}
	}

	Data
		#|HTTP/1.1 200 OK
		#|Date:Sun,  28  Jun  2020  
		#|	08:01:24  GMT  
		#|Content-Type: text/html; charset=UTF-8
		#|Set-Cookie: __Secure-ID=123; Secure; Domain=example.com
		#|Set-Cookie: __Host-ID=123; Secure; Path=/
		#|W3m-control: GOTO http://www.example.com/
		#|W3m-control: EXEC_SHELL echo 'EXEC_SHELLのテスト'
		#|
		#|<!DOCTYPE html>
		#|<html></html>
	End

	Example 'No arguments'
		expected () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Sun, 28 Jun 2020 08:01:24 GMT${SHELLSPEC_CR}
			#|Content-Type: text/html; charset=UTF-8${SHELLSPEC_CR}
			#|Set-Cookie: __Secure-ID=123; Secure; Domain=example.com${SHELLSPEC_CR}
			#|Set-Cookie: __Host-ID=123; Secure; Path=/${SHELLSPEC_CR}
			#|W3m-control: GOTO http://www.example.com/, EXEC_SHELL echo =?UTF-8?B?J0VYRUNfU0hFTEzjga7jg4bjgrnjg4gn?=${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
			#|<!DOCTYPE html>
			#|<html></html>
		}

		When call normalizehttpmsg
		The output should equal "$(expected)"
	End

	Example 'No arguments'
		expected () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Sun, 28 Jun 2020 08:01:24 GMT${SHELLSPEC_CR}
			#|Content-Type: text/html; charset=UTF-8${SHELLSPEC_CR}
			#|Set-Cookie: __Secure-ID=123; Secure; Domain=example.com${SHELLSPEC_CR}
			#|Set-Cookie: __Host-ID=123; Secure; Path=/${SHELLSPEC_CR}
			#|W3m-control: GOTO http://www.example.com/${SHELLSPEC_CR}
			#|W3m-control: EXEC_SHELL echo =?UTF-8?B?J0VYRUNfU0hFTEzjga7jg4bjgrnjg4gn?=${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
			#|<!DOCTYPE html>
			#|<html></html>
		}

		When call normalizehttpmsg --uncombined 'Set-Cookie,W3m-control'
		The output should equal "$(expected)"
	End

	Example 'No arguments'
		expected () {
			%text:expand
			#|HTTP/1.1 200 OK${SHELLSPEC_CR}
			#|Date: Sun, 28 Jun 2020 08:01:24 GMT${SHELLSPEC_CR}
			#|Content-Type: text/html; charset=UTF-8${SHELLSPEC_CR}
			#|Set-Cookie: __Secure-ID=123; Secure; Domain=example.com${SHELLSPEC_CR}
			#|Set-Cookie: __Host-ID=123; Secure; Path=/${SHELLSPEC_CR}
			#|W3m-control: GOTO http://www.example.com/${SHELLSPEC_CR}
			#|W3m-control: =?UTF-8?B?RVhFQ19TSEVMTCBlY2hvICdFWEVDX1NIRUxM44Gu44OG44K544OIJw==?=${SHELLSPEC_CR}
			#|${SHELLSPEC_CR}
			#|<!DOCTYPE html>
			#|<html></html>
		}

		When call normalizehttpmsg  --uncombined 'Set-Cookie,W3m-control' --unstructured 'W3m-control'
		The output should equal "$(expected)"
	End
End
