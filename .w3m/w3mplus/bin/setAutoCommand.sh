#!/usr/bin/env sh

##
# Set a auto command.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-12-15
# @since 2019-12-15
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

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
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-c' | '--config')
			config="${2}"
			shift 2
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... CALL URI COMMAND
				Set a auto command.

				 -c, --config  configuration file
				 -h, --help    display this help and exit
			EOF

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

			while [ 1 -le "${#}" ]; do
				arg=$(printf '%s\n' "${1}" | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '$');

				args="${args}${args:+ }'${arg%?$}'"
				shift
			done
			;;
		# 複合ショートオプション
		'-'[!-][!-]*)
			option=$(printf '%s' "${1}" | cut -c '2'; printf '$')
			options=$(printf '%s' "${1}" | cut -c '3-'; printf '$')

			shift
			# `-abc` を `-a -bc` に変換して再セットする
			set -- "-${option%$}" "-${options%$}" ${@+"${@}"}
			;;
		# その他の無効なオプション
		'-'*)
			cat <<- EOF 1>&2
				${0}: invalid option -- '${1}'
				Try '${0} --help' for more information.
			EOF

			exit 64 # EX_USAGE </usr/include/sysexits.h>
			;;
		# その他のオプション以外の引数
		*)
			break
			;;
	esac
done

directory=$(dirname "${config}"; printf '$')
mkdir -p "${directory%?$}"
: >>"${config}"

call="${1}"

if [ "${#}" -le 3 ]; then
	check="${2}"
	command="${3}"
else
	check=''
	command=''
	shift

	while [ 1 -le "${#}" ]; do
		if [ "${1}" = ';' ]; then
			shift
			break
		fi

		check="${check}${check:+ }${1}"
		shift
	done

	for arg in ${@+"${@}"}; do
		command="${command}${command:+; }${arg}"
	done

	if [ 2 -le "${#}" ]; then
		command="COMMAND ${command}"
	fi
fi

if [ -z "${check}" ] || [ "${check}" = ';' ]; then
	check='true'
fi

if [ -n "${call}" ]; then
	escaped=$(printf '%s\t%s\t' "${call}" "${check}" | sed -e 's/[].\*/[]/\\&/g; 1s/^^/\\^/; $s/$$/\\$/')
	field=$(printf '%s\t%s\t%s\t%s\n' "${call}" "${check}" "${command}" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')")
	html=$(printf '%s\n' "${field}" | outputHtml)
	replaced=$(sed -e "/^${escaped}/!d" <"${config}" | outputHtml)

	{
		sed -e "/^\$/d; /^${escaped}/d" "${config}"
		printf '%s\n' "${field}"
	} | sort -o "${config}"

	if [ -z "${replaced}" ]; then
		printHtml.sh 'Added auto command' "<h1>Added auto command</h1>${html}"
	else
		printHtml.sh 'Updated auto command' "<h1>Updated auto command</h1>${html}<h1>Replaced auto command</h1>${replaced}"
	fi
else
	httpResposeW3mBack.sh
fi
