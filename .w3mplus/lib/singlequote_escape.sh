singlequote_escape() {
	set "${1}" "${2-}" ''

	until [ "${2#*\'}" = "${2}" ]; do
		set -- "${1}" "${2#*\'}" "${3}${2%%\'*}'\"'\"'"
	done

	eval "${1}=\"\${3}\${2}\""
}
