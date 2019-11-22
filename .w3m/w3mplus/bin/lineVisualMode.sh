#!/usr/bin/env sh

set -eu

url=$(printf '%s' "${1-${W3M_URL-}}" | cut -d '#' -f 1)
line="${2-${W3M_CURRENT_LINE-1}}"

if [ -n "${url}" ] && [ -n "${line}" ]; then
	visualStart="${W3MPLUS_PATH}/visualStart"

	[ -e "${visualStart}" ] || echo '  0' >"${visualStart}"

	startUrl=$(cut -d ' ' -f 1 "${visualStart}")
	startLine=$(cut -d ' ' -f 2 "${visualStart}")
	startTime=$(cut -d ' ' -f 3 "${visualStart}" | tr -d 'TZ:-' | utconv)

	if [ "${url}" = "${startUrl}" ] && [ "$(date -u '+%Y%m%d%H%M%S' | utconv)" -lt "$((startTime + W3MPLUS_VISUAL_TIMEOUT))" ]; then
		if [ "${startLine}" -le "${line}" ]; then
			endLine="${line}"
		else
			endLine="${startLine}"
			startLine="${line}"
		fi

		tmpDir=$(mktemp -d)
		tmpFile="${tmpDir}/print"
		yankFile=$(date "+${W3MPLUS_YANK_FILE}")
		mkdir -p "$(dirname "${yankFile}")"

		httpResponseW3mBack.sh - <<- EOF
			W3m-control: PRINT ${tmpFile}
			W3m-control: EXEC_SHELL $(
				tr '\n' ' ' <<- SHELL_EOF
					sed -n -e '${startLine},${endLine}p' '${tmpFile}' | tee -a '${yankFile}';
					printf 'Add to: %s' '${yankFile}';
					rm -fr '${tmpDir}';
				SHELL_EOF
			)
		EOF

		: >"${visualStart}"

		exit 0
	else
		printf '%s %d %s\n' "${url}" "${line}" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >"${visualStart}"

		httpResponseW3mBack.sh "W3m-control: EXEC_SHELL echo 'Start visual mode from line ${line}'"

		exit 0
	fi
fi

httpResponseW3mBack.sh
