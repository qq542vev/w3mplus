regex_escape() {
	set -- "${1}" "${2}" "${3-}" ''
	until [ "${2#*'\'}" = "${2}" ]; do
		set -- "${1}" "${2#*'\'}" "${3-}" "${4}${2%%'\'*}\\\\"
	done

	set -- "${1}" "${4}${2}" "${3-}" ''
	until [ "${2#*'['}" = "${2}" ]; do
		set -- "${1}" "${2#*'['}" "${3-}" "${4}${2%%'['*}\\["
	done

	set -- "${1}" "${4}${2}" "${3-}" ''
	until [ "${2#*'.'}" = "${2}" ]; do
		set -- "${1}" "${2#*'.'}" "${3-}" "${4}${2%%'.'*}\\."
	done

	set -- "${1}" "${4}${2}" "${3-}" ''
	until [ "${2#*'*'}" = "${2}" ]; do
		set -- "${1}" "${2#*'*'}" "${3-}" "${4}${2%%'*'*}\\*"
	done

	set -- "${1}" "${4}${2}" "${3-}" ''
	until [ "${2#*'^'}" = "${2}" ]; do
		set -- "${1}" "${2#*'^'}" "${3-}" "${4}${2%%'^'*}\\^"
	done

	set -- "${1}" "${4}${2}" "${3-}" ''
	until [ "${2#*'$'}" = "${2}" ]; do
		set -- "${1}" "${2#*'$'}" "${3-}" "${4}${2%%'$'*}\\$"
	done

	case "${3:-BRE}" in
		'ERE' | 'SED-ERE')
			set -- "${1}" "${4}${2}" "${3-}" ''
			until [ "${2#*'+'}" = "${2}" ]; do
				set -- "${1}" "${2#*'+'}" "${3-}" "${4}${2%%'+'*}\\+"
			done

			set -- "${1}" "${4}${2}" "${3-}" ''
			until [ "${2#*'?'}" = "${2}" ]; do
				set -- "${1}" "${2#*'?'}" "${3-}" "${4}${2%%'?'*}\\?"
			done

			set -- "${1}" "${4}${2}" "${3-}" ''
			until [ "${2#*'|'}" = "${2}" ]; do
				set -- "${1}" "${2#*'|'}" "${3-}" "${4}${2%%'|'*}\\|"
			done

			set -- "${1}" "${4}${2}" "${3-}" ''
			until [ "${2#*'('}" = "${2}" ]; do
				set -- "${1}" "${2#*'('}" "${3-}" "${4}${2%%'('*}\\("
			done

			set -- "${1}" "${4}${2}" "${3-}" ''
			until [ "${2#*')'}" = "${2}" ]; do
				set -- "${1}" "${2#*')'}" "${3-}" "${4}${2%%')'*}\\)"
			done

			set -- "${1}" "${4}${2}" "${3-}" ''
			until [ "${2#*'{'}" = "${2}" ]; do
				set -- "${1}" "${2#*'{'}" "${3-}" "${4}${2%%'{'*}\\{"
			done
			;;
	esac

	case "${3:-BRE}" in
		'SED-BRE' | 'SED-ERE')
			set -- "${1}" "${4}${2}" "${3-}" ''
			until [ "${2#*'/'}" = "${2}" ]; do
				set -- "${1}" "${2#*'/'}" "${3-}" "${4}${2%%'/'*}\\/"
			done
			;;
	esac

	eval "${1}=\"\${4}\${2}\""
}
