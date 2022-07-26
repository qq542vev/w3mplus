. 'abspath.sh'

path_to_fileurl() {
	abspath "${1}" "${2}"

	eval "${1}=\"file://\$(printf '%s' \"\${${1}}\" | urlencode | sed -e 's/%2F/\//g')\""
}
