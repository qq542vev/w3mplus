#!/usr/bin/env sh

# 初期化
set -eu
umask 0022
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

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
