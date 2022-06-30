append_array_posix() {
	while [ 2 -le "${#}" ]; do
		__append_array_posix "${1}" "${2}"
		eval "shift 2; set -- '${1}' \"\${@}\""
	done
}

__append_array_posix() {
	set "${1}" "${2-}" ''

	until [ "${2#*\'}" = "${2}" ]; do
		set -- "${1}" "${2#*\'}" "${3}${2%%\'*}'\"'\"'"
	done

	eval "${1}=\"\${${1}-}\${${1}:+ }'\${3}\${2}'\""
}
