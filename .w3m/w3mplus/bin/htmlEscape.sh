#!/usr/bin/env sh

set -eu

escape () {
	sed -e "s/&/\\&amp;/g; s/</\\&lt;/g; s/>/\\&gt;/g; s/\"/\\&quot;/g; s/'/\\&#x27;/g"
}

if [ "${#}" -eq 0 ]; then
	escape
else
	for file; do
		case "${file}" in
			'-')
				escape
				;;
			*)
				escape <"${file}"
				;;
		esac
	done
fi
