#!/usr/bin/env sh

### Script: install
##
## w3mplus をインストールする。
##
## Metadata:
##
##	 author - qq542vev <https://purl.org/meta/me/>
##	 version - 0.1.0
##	 date - 2022-07-13
##	 since - 2022-07-13
##	 copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##	 license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##	 package - w3mplus
##
## See Also:
##
##	 * Project homepage - <https://github.com/qq542vev/w3mplus>
##	 * Bag report - <https://github.com/qq542vev/w3mplus/issues>

VERSION='install 0.1.0'

. 'initialize.sh'
. 'option_error.sh'
. 'regex_match.sh'

# @getoptions
parser_definition() {
	setup REST abbr:true error:optuon_error plus:true no:0 help:usage \
		-- 'Usage:' "  ${2##*/} [OPTION]..." \
		'' 'Options:'

	param binDir     --bin-dir     init:'binDir="${HOME}/bin"'          var:PATH -- 'PATH に bin をインストールする'
	param pass       -p --pass     init:'pass=$(tr -dc "a-zA-Z0-9" <"/dev/urandom" | fold -w "32" | head -n "1")' validate:'regex_match "${OPTARG}" "^[0-9A-Za-z]*$"' var:ALPHANUM -- 'pass のための文字列を指定する'
	param sourceBin     --source-bin     init:'sourceBin=$(dirname -- "${0}"; printf "_"); sourceBin="${sourceBin%?_}/bin"' var:DIRECTORY -- 'インストールする bin を指定する'
	param sourceW3m     --source-w3m     init:'sourceW3m=$(dirname -- "${0}"; printf "_"); sourceW3m="${sourceW3m%?_}/.w3m"' var:DIRECTORY -- 'インストールする .w3m を指定する'
	param sourceW3mplus --source-w3mplus init:'sourceW3mplus=$(dirname -- "${0}"; printf "_"); sourceW3mplus="${sourceW3mplus%?_}/.w3mplus"' var:DIRECTORY -- 'インストールする .w3mplus を指定する'
	param w3mDir     --w3m-dir     init:'w3mDir="${HOME}/.w3m"'         var:PATH -- 'PATH に .w3m をインストールする'
	param w3mplusDir --w3mplus-dir init:'w3mplusDir="${HOME}/.w3mplus"' var:PATH -- 'PATH に .w3mplus をインストールする'
	disp  :usage     -h --help     -- 'このヘルプを表示して終了する'
	disp  VERSION    -v --version  -- 'バージョン情報を表示して終了する'

	msg -- '' 'Exit Status:' \
		'    0 - successful termination' \
		'   64 - command line usage error' \
		'   65 - data format error' \
		'   66 - cannot open input' \
		'   67 - addressee unknown' \
		'   68 - host name unknown' \
		'   69 - service unavailable' \
		'   70 - internal software error' \
		"   71 - system error (e.g., can't fork)" \
		'   72 - critical OS file missing' \
		"   73 - can't create (user) output file" \
		'   74 - input/output error' \
		'   75 - temp failure; user is invited to retry' \
		'   76 - remote error in protocol' \
		'   77 - permission denied' \
		'   78 - configuration error' \
		'  129 - received SIGHUP' \
		'  130 - received SIGINT' \
		'  131 - received SIGQUIT' \
		'  143 - received SIGTERM'
}
# @end

# @gengetoptions parser -i parser_definition parse "${1}"
# @end

eval "$(getoptions parser_definition parse "${0}")"
parse ${@+"${@}"}
eval "set -- ${REST}"

baseDir=$(dirname -- "${0}"; printf '_')
baseDir="${baseDir%?_}"
tmpDir="${baseDir}/tmp"
shellScript=$(
	cat <<-'EOF'
	pass="${1}"
	shift

	for file in ${@+"${@}"}; do
		sed -e "s/\\\$(PASS)/${pass}/g" -- "${file}" >"${file}.tmp"

		mv -f "${file}.tmp" "${file}"
	done
	EOF
)

rm -fr -- "${tmpDir}"
mkdir -p -- "${tmpDir}"

for value in 'sourceBin:bin' 'sourceW3m:.w3m' 'sourceW3mplus:.w3mplus'; do
	eval "sourceDir=\"\${${value%%:*}}\""

	if [ '!' -d "${sourceDir}" ]; then
　	cat <<-EOF >&2
			${0##*/}: '${sourceDir}' はディレクトリではありません。
			詳細については '${0##*/} --help' を実行してください。
		EOF

		endCall "${EX_DATAERR}"
	fi

	cp -R -- "${sourceDir}" "${tmpDir}/${value##*:}"
done

printf '%s' "${pass}" >"${tmpDir}/.w3mplus/pass"

find -- "${tmpDir}/.w3m" -type f -exec sh -c "${shellScript}" 'sh' "${pass}" '{}' '+'

for value in 'bin:binDir' '.w3m:w3mDir' '.w3mplus:w3mplusDir'; do
	eval "distDir=\"\${${value##*:}}\""

	case "${distDir}" in
		?*)
			(
				mkdir -p -- "${distDir}"
				cd -- "${tmpDir}/${value%%:*}"
				find -- . -path './*' -prune -exec cp -fR -- '{}' "${distDir}" ';'
			)
			;;
	esac
done
