#!/usr/bin/env sh

## File: setAutoCommand.sh
##
## Set a auto command.
##
## Usage:
##
##   (start code)
##   setAutoCommand.sh [OPTION]... CALL [CHECK] [COMMAND]...
##   (end)
##
## Options:
##
##   -c, --config=FILE - configuration file
##   -h, --help        - display this help and exit.
##   -v, --version     - output version information and exit.
##
## Exit Status:
##
##   0 - Program terminated normally.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.4
##   date - 2020-02-20
##   since 2019-12-15
##   copyright - Copyright (C) 2019-2020 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/w3mplus>
##   * Bag report - <https://github.com/qq542vev/w3mplus/issues>

# 初期化
set -efu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'


: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/functions"

outputHtml () {
	while IFS='	' read -r 'call' 'check' 'command' 'date'; do
		cat <<- EOF
			<dl>
				<dt>call type</dt>
				<dd>$(printf '%s' "${call}" | htmlEscape.sh)</dd>

				<dt>check command</dt>
				<dd><code>$(printf '%s' "${check}" | htmlEscape.sh)</code></dd>

				<dt>w3m command</dt>
				<dd><code>$(printf '%s' "${command}" | htmlEscape.sh)</code></dd>

				<dt>date</dt>
				<dd><date>$(printf '%s' "${date}" | htmlEscape.sh)</date></dd>
			</dl>
		EOF
	done
}

# 各変数に既定値を代入する
config="${W3MPLUS_PATH}/autoCommand"

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--config')
			config="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			usage
			exit
			;;
		# バージョン情報を表示して終了する
		'-v' | '--version')
			version
			exit
			;;
		# `--name=value` 形式のロングオプション
		'--'[!-]*'='*)
			option="${1}"
			shift
			# `--name value` に変換して再セットする
			set -- "${option%%=*}" "${option#*=}" ${@+"${@}"}
			;;
		# 以降はオプション以外の引数
		'--')
			shift
			break
			;;
		# 複合ショートオプション
		'-'[!-][!-]*)
			option=$(printf '%s\n' "${1}" | cut -c '2'; printf '$')
			options=$(printf '%s\n' "${1}" | cut -c '3-'; printf '$')

			shift
			# `-abc` を `-a -bc` に変換して再セットする
			set -- "-${option%?$}" "-${options%?$}" ${@+"${@}"}
			;;
		# その他の無効なオプション
		'-'*)
			cat <<- EOF 1>&2
				${0##*/}: invalid option -- '${1}'
				Try '${0##*/} --help' for more information.
			EOF

			exitStatus="${EX_USAGE}"; exit
			;;
		# その他のオプション以外の引数
		*)
			break
			;;
	esac
done

directory=$(dirname -- "${config}"; printf '$')
mkdir -p -- "${directory%?$}"
: >>"${config}"

call="${1}"

if [ "${#}" -eq 2 ]; then
	check="${2}"
elif [ "${#}" -eq 3 ]; then
	check="${2}"
	command="${3}"
else
	shift

	while [ 1 -le "${#}" ]; do
		if [ "${1}" = ';' ]; then
			shift
			break
		fi

		check="${check-}${check+ }${1}"
		shift
	done

	for arg in ${@+"${@}"}; do
		command="${command-}${command+; }${arg}"
	done

	if [ 2 -le "${#}" ]; then
		command="COMMAND ${command}"
	fi
fi

escaped=$(printf '%s\t%s' "${call}" "${check-}${check:+	}" | sed -e 's/[].\*/[]/\\&/g; 1s/^^/\\^/; $s/$$/\\$/')
field=''

case "${command+1}" in '1')
	field=$(printf '%s\t%s\t%s\t%s\n$' "${call}" "${check}" "${command}" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')")
	field="${field%$}"
	;;
esac

addList=$(printf '%s' "${field}" | outputHtml)
deleteList=$(sed -e "/^${escaped}/!d" "${config}" | outputHtml)

if [ -z "${addList}" ] && [ -z "${deleteList}" ]; then
		httpResposeW3mBack.sh
		exit
fi

{
	sed -e "/^\$/d; /^${escaped}/d" -- "${config}"
	printf '%s' "${field}"
} | sort -o "${config}"

if [ -n "${addList}" ]; then
	addList="<h1>Added auto command</h1>${addList}"
fi

if [ -n "${deleteList}" ]; then
	deleteList="<h1>Deleted auto command </h1>${deleteList}"
fi

printRedirect.sh "data:text/html;base64,$("${W3MPLUS_TEMPLATE_HTML}" -t "Set auto command '${call}'" -c "${addList}${deleteList}" | base64 | tr -d '\n')"
