# https://qiita.com/ko1nksm/items/88d5b7ac3b1db8778452
abspath() {
	case $2 in
		/*) set -- "$1" "$2/" "" ;;
		*) set -- "$1" "${3:-$PWD}/$2/" ""
	esac

	while [ "$2" ]; do
		case ${2%%/*} in
			"" | .) set -- "$1" "${2#*/}" "$3" ;;
			..) set -- "$1" "${2#*/}" "${3%/*}" ;;
			*) set -- "$1" "${2#*/}" "$3/${2%%/*}"
		esac
	done

	eval "$1=\"/\${3#/}\""
}
