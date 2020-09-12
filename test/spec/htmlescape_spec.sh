#!/usr/bin/env shellspec

## File: htmlescape_spec.sh
##
## Test htmlescape.
##
## Usage:
##
##   (start code)
##   shellspec htmlescape_spec.sh
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

Describe 'Test htmlescape'
	htmlescape () {
		"${W3MPLUS_HOME}/bin/htmlescape" ${@+"${@}"}
	}

	Data "&'\"<>"

	Example 'Basic HTML Escape'
		When call htmlescape
		The output should equal '&amp;&#x27;&quot;&lt;&gt;'
	End

	Example 'Single Quote Escape'
		When call htmlescape --escape 'single'
		The output should equal '&amp;&#x27;"&lt;&gt;'
	End

 	Example 'Double Quote Escape'
		When call htmlescape --escape 'double'
		The output should equal "&amp;'&quot;&lt;&gt;"
	End
End
