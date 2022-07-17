option_error() {
	printf '%s: %s\n' "${0##*/}" "${1}" >&2
	printf '%s\n' "詳細については '${0##*/} --help' を実行してください。" >&2

	endCall "${EX_USAGE}"
}
