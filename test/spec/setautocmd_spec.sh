#!/usr/bin/env shellspec

## File: setautocmd_spec.sh
##
## Test setautocmd.
##
## Usage:
##
##   (start code)
##   shellspec setautocmd_spec.sh
##   (end)
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2020-09-21
##   since - 2020-09-16
##   copyright - Copyright (C) 2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

Describe 'Test setautocmd'
	setup () {
		tmpFile=$(mktemp)

		cat <<- 'EOF' >"${tmpFile}"
			auto	grep -qFx 'https://www.example.com/page/a' && echo 'auto 1'	2020-09-20T00:00:00Z
			manual	grep -qFx 'https://www.example.com/page/a' && echo 'manual 1'	2020-09-20T00:00:00Z
		EOF
	}

	cleanup () {
		rm -f "${tmpFile}"
	}

	Before 'setup'
	After 'cleanup'

	setautocmd () {
		env 'W3MPLUS_TEMPLATE_HTTP=template/http' 'W3MPLUS_TEMPLATE_HTML=template/html' "${W3MPLUS_PATH}/bin/setautocmd" --config "${tmpFile}" ${@+"${@}"}
	}

	stdout () {
		template/http | sed -n -e "/^$(printf '\r')\$/{q}; p"
	}

	Example 'Test: add auto command'
		output () {
			%text
			#|auto	grep -qFx 'https://www.example.com/page/a' && echo 'auto 1'	2020-09-20T00:00:00Z
			#|manual	grep -qFx 'https://www.example.com/page/a' && echo 'manual 1'	2020-09-20T00:00:00Z
			#|manual	grep -qFx 'https://www.example.com/page/b' && echo 'manual 2'	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
		}

		When call setautocmd manual	grep -qFx "'https://www.example.com/page/b'" '&&' echo "'manual 2'"
		The output should start with "$(stdout)"
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End

	Example 'Test: update auto command'
		output () {
			%text
			#|auto	grep -qFx 'https://www.example.com/page/a' && echo 'auto 1'	2020-09-20T00:00:00Z
			#|manual	grep -qFx 'https://www.example.com/page/a' && echo 'manual 1'	[2-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9]Z
		}

		When call setautocmd manual	grep -qFx "'https://www.example.com/page/a'" '&&' echo "'manual 1'"
		The output should start with "$(stdout)"
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End

	Example 'Test: delete auto command'
		output () {
			%text
			#|auto	grep -qFx 'https://www.example.com/page/a' && echo 'auto 1'	2020-09-20T00:00:00Z
		}

		When call setautocmd manual
		The output should start with "$(stdout)"
		The status should equal '0'
		The contents of file "${tmpFile}" should match pattern "$(output)"
	End
End
