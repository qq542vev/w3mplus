error() {
	printf '%s\n' "${1}" >&2
	endCall "${EX_USAGE}"
}
