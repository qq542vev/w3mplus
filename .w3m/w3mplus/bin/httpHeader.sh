#!/usr/bin/env sh

# 初期化
set -eu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# 終了時の動作を設定する
trap 'exit 129' 1 # SIGHUP
trap 'exit 130' 2 # SIGINT
trap 'exit 131' 3 # SIGQUIT
trap 'exit 143' 15 # SIGTERM

case "${LANG}" in 'C')
	LANG='en_US.US-ASCII'
	;;
esac

trim () (
	sed -e '1s/^[\t ]*//; $s/[\t ]*$//'
)

printHeader () (
	name=$(printf '%s' "${1}" | trim)
	value=$(printf '%s' "${2}" | trim)

	if [ -n "${name}" ] && [ -n "${value}" ]; then
		if printf '%s' "${value}" | grep -q -e '[^\t !-}]'; then
			value=$(printf '=?%s?B?%s?=' "${LANG#*.}" "$(printf '%s' "${value}" | base64 | tr -d '\n')")
		fi

		printf '%s: %s\r\n' "${name}" "${value}"
	fi
)

printHeaders () (
	printf '%s\n' "${1:-}" | while IFS=':'; read -r 'name' 'value'; do
		printHeader "${name}" "${value}"
	done
)

if [ "${#}" -eq 0 ]; then
	printHeaders "$(cat)"
else
	while [ 1 -le "${#}" ]; do
		case "${1}" in
			*:*)
				printHeader "${1%%:*}" "${1#*}"
				shift
				;;
			*)
				printHeader "${1}" "${2-}"
				shift 2
				;;
		esac
	done
fi
