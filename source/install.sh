#!/usr/bin/env sh

### Script: install.sh
##
## w3mplus をインストールする。
##
## Metadata:
##
##   id - 1cd3c307-ff93-487a-ac7d-dc21901fec47
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 0.1.1
##   date - 2022-10-09
##   since - 2022-07-13
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bug report at https://github.com/qq542vev/w3mplus/issues>
##
## Help Output:
##
## ------ Text ------
## Usage:
##   install.sh [OPTION]...
##
## Options:
##           --dest-bin PATH     PATH に bin をインストールする
##           --dest-w3m PATH     PATH に .w3m をインストールする
##           --dest-w3mplus PATH PATH に .w3mplus をインストールする
##   -p,     --pass ALPHANUM     pass のための文字列を指定する
##   -s,     --{no-}silent       処理中の表示を行わない
##           --source-bin DIRECTORY 
##                               インストールする bin を指定する
##           --source-w3m DIRECTORY 
##                               インストールする .w3m を指定する
##           --source-w3mplus DIRECTORY 
##                               インストールする .w3mplus を指定する
##   -h,     --help              このヘルプを表示して終了する
##   -v,     --version           バージョン情報を表示して終了する
##
## Exit Status:
##     0 - successful termination
##    64 - command line usage error
##    65 - data format error
##    66 - cannot open input
##    67 - addressee unknown
##    68 - host name unknown
##    69 - service unavailable
##    70 - internal software error
##    71 - system error (e.g., can't fork)
##    72 - critical OS file missing
##    73 - can't create (user) output file
##    74 - input/output error
##    75 - temp failure; user is invited to retry
##    76 - remote error in protocol
##    77 - permission denied
##    78 - configuration error
##   129 - received SIGHUP
##   130 - received SIGINT
##   131 - received SIGQUIT
##   143 - received SIGTERM
## ------------------

readonly 'VERSION=install.sh 0.1.0'

. 'initialize.sh'
. 'option_error.sh'
. 'regex_match.sh'

# @getoptions
parser_definition() {
	setup REST abbr:true error:optuon_error plus:true no:0 help:usage \
		-- 'Usage:' "  ${2##*/} [OPTION]..." \
		'' 'Options:'

	param destBin     --dest-bin     init:'destBin="${HOME}/bin"'          var:PATH -- 'PATH に bin をインストールする'
	param destW3m     --dest-w3m     init:'destW3m="${HOME}/.w3m"'         var:PATH -- 'PATH に .w3m をインストールする'
	param destW3mplus --dest-w3mplus init:'destW3mplus="${HOME}/.w3mplus"' var:PATH -- 'PATH に .w3mplus をインストールする'
	param pass        -p --pass      init:'pass=$(tr -dc "a-zA-Z0-9" <"/dev/urandom" | fold -w "32" | head -n "1")' validate:'regex_match "${OPTARG}" "^[0-9A-Za-z]*$"' var:ALPHANUM -- 'pass のための文字列を指定する'
	flag  silentFlag    -s --{no-}silent init:@no -- '処理中の表示を行わない'
	param sourceBin     --source-bin     init:'sourceBin=$(dirname -- "${0}"; printf "_"); sourceBin="${sourceBin%?_}/bin"' var:DIRECTORY -- 'インストールする bin を指定する'
	param sourceW3m     --source-w3m     init:'sourceW3m=$(dirname -- "${0}"; printf "_"); sourceW3m="${sourceW3m%?_}/.w3m"' var:DIRECTORY -- 'インストールする .w3m を指定する'
	param sourceW3mplus --source-w3mplus init:'sourceW3mplus=$(dirname -- "${0}"; printf "_"); sourceW3mplus="${sourceW3mplus%?_}/.w3mplus"' var:DIRECTORY -- 'インストールする .w3mplus を指定する'
	disp  :usage      -h --help      -- 'このヘルプを表示して終了する'
	disp  VERSION     -v --version   -- 'バージョン情報を表示して終了する'

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
	cat <<-'__EOF__'
	pass="${1}"
	shift

	for file in ${@+"${@}"}; do
		sed -e "s/\\\$(PASS)/${pass}/g" -- "${file}" >"${file}.tmp"

		mv -f "${file}.tmp" "${file}"
	done
	__EOF__
)

rm -fr -- "${tmpDir}"
mkdir -p -- "${tmpDir}"

for value in 'sourceBin:bin' 'sourceW3m:.w3m' 'sourceW3mplus:.w3mplus'; do
	eval "sourceDir=\"\${${value%%:*}}\""

	case "${silentFlag}" in '0')
		printf "'%s' を確認中...\\n" "${sourceDir}" >&2
	esac

	if [ '!' -d "${sourceDir}" ]; then
		printf "%s: '%s' はディレクトリではありません。\\n" "${0##*/}" "${sourceDir}" >&2
		printf "詳細については '%s' を実行してください。\\n" "${0##*/} --help" >&2

		end_call "${EX_DATAERR}"
	fi

	cp -R -- "${sourceDir}" "${tmpDir}/${value##*:}"
done

printf '%s' "${pass}" >"${tmpDir}/.w3mplus/pass"

case "${silentFlag}" in '0')
	printf "'.w3m' のファイルを設定中...\\n" >&2
esac

find -- "${tmpDir}/.w3m" -type f -exec sh -c "${shellScript}" 'sh' "${pass}" '{}' '+'

for value in 'bin:destBin' '.w3m:destW3m' '.w3mplus:destW3mplus'; do
	eval "destDir=\"\${${value##*:}}\""

	case "${destDir}" in ?*)
		(
			case "${silentFlag}" in '0')
				printf "'%s' を '%s' にインストール中...\\n" "${value%%:*}" "${destDir}" >&2
			esac

			if [ '!' -e "${destDir}" ]; then
				mkdir -p -- "${destDir}"

				rm -fr "${destDir}"

				cp -R -- "${tmpDir}/${value%%:*}" "${destDir}"
			elif [ -d "${destDir}" ]; then
				find -- "${tmpDir}/${value%%:*}/" -path '*[!/]' -prune -exec cp -fRP -- '{}' "${destDir}" ';'
			else
				printf "%s: '%s' はディレクトリではありません。\\n" "${0##*/}" "${destDir}" >&2
				printf "詳細については '%s' を実行してください。\\n" "${0##*/} --help" >&2

				end_call "${EX_DATAERR}"
			fi
		)
	esac
done

case "${silentFlag}" in '0')
	printf 'インストール完了\n' >&2
esac
