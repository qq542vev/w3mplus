datauri() {
	printf 'data:%s;base64,' "${1}"
	shift
	base64 -- ${@+"${@}"} | tr -d '\n'
}
