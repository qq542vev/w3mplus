#!/usr/bin/env sh

set -eu

file="${W3MPLUS_PATH}/quickmark"
: >>"${file}"
marks=$(cat "${file}")

if [ "${#}" -eq 0 ]; then
	set '0-9A-Za-z'
fi

for mark; do
	if expr "${mark}" : '^\([0-9A-Za-z]\{1,\}\(-[0-9A-Za-z]\{1,\}\)*\)$' >/dev/null; then
		marks=$(printf '%s\n' "${marks}" | sed -e "/^[${mark}] /d")
	else
		printf 'Usage: %s [mark1] [mark2]...\n' "${0}" 2>&1
		exit 64
	fi
done

printf '%s\n' "${marks}" >"${file}"

httpResponseW3mBack.sh
