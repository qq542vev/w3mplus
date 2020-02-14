#!/usr/bin/env sh

##
# Cookie management.
#
# @author qq542vev
# @version 1.0.2
# @date 2020-02-13
# @since 2019-01-27
# @copyright Copyright (C) 2020 qq542vev. Some rights reserved.
# @licence CC-BY <https://creativecommons.org/licenses/by/4.0/>
##

# 初期化
set -eu
umask '0022'
IFS=$(printf ' \t\n$'); IFS="${IFS%$}"
export 'IFS'

# 終了時の動作を設定する
trap 'endCall' 0 # EXIT
trap 'endCall; exit 129' 1 # SIGHUP
trap 'endCall; exit 130' 2 # SIGINT
trap 'endCall; exit 131' 3 # SIGQUIT
trap 'endCall; exit 143' 15 # SIGTERM

: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/config"

# 終了時に一時ファイルを削除する
endCall () {
	rm -f -- ${tmpFile+"${tmpFile}"}
}

# 各変数に既定値を代入する
config="${W3MPLUS_W3M_CONFIG}"
blacklist=''
whitelist=''
subdomain='0'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-b' | '--blacklist')
			case "${2}" in
				'add' | 'delete' | 'toggle')
					blacklist="${2}"
					shift 2
					;;
				*)
					cat <<- EOF 1>&2
						${0##*/}: invalid option -- '${1}'
						The only available values for the '${1}' are add, delete, and toggle.
					EOF

					exit 64 # EX_USAGE </usr/include/sysexits.h>
					;;
			esac
			;;
		'-c' | '--config')
			config="${2}"
			shift 2
			;;
		'-s' | '--subdomain')
			subdomain='1'
			shift
			;;
		'-w' | '--whitelist')
			case "${2}" in
				'add' | 'delete' | 'toggle')
					whitelist="${2}"
					shift 2
					;;
				*)
					cat <<- EOF 1>&2
						${0##*/}: invalid option -- '${1}'
						The only available values for the '${1}' are add, delete, and toggle.
					EOF

					exit 64 # EX_USAGE </usr/include/sysexits.h>
					;;
			esac
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0##*/} [OPTION]... [DOMAIN]...
				$(sed -e '/^##$/,/^##$/!d; /^# /!d; s/^# //; q' -- "${0}")

				 -b, --blacklist=TYPE  black list type (add, delete, toggle)
				 -s, --subdomain       also applies to subdomains
				 -w, --whitelist=TYPE  white list type (add, delete, toggle)
				 -h, --help            display this help and exit
				 -v, --version         output version information and exit
			EOF

			exit
			;;
		'-v' | '--version')
			cat <<- EOF
				${0##*/} (w3mplus) $(sed -n -e 's/^# @version //p' -- "${0}") (Last update: $(sed -n -e 's/^# @date //p' -- "${0}"))
				$(sed -n -e 's/^# @copyright //p' -- "${0}")
				License: $(sed -n -e 's/^# @licence //p' -- "${0}")
			EOF

			exit
			;;
		# 標準入力を処理する
		'-')
			arg=$( (cat; echo) | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '$');

			args="${args}${args:+ }'${arg%?$}'"
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

			exit 64 # EX_USAGE </usr/include/sysexits.h>
			;;
		# その他のオプション以外の引数
		*)
			arg=$(printf '%s\n' "${1}" | sed -e "s/'\\{1,\\}/'\"&\"'/g"; printf '$');

			args="${args}${args:+ }'${arg%?$}'"
			shift
			;;
	esac
done

directory=$(dirname -- "${config}"; printf '$')
mkdir -p -- "${directory%?$}"
: >>"${config}"

# オプション以外の引数を再セットする
eval set -- "${args}"

if [ "${#}" -eq 0 ]; then
	set -f
	set -- $(cat)
	set +f
fi

uriPattern='^\(\([^:/?#]\{1,\}\):\)\{0,1\}\(\/\/\([^@/?#]@\)\{0,1\}\([^/?#]*\)\(:[^/?#]*\)\{0,1\}\)\{0,1\}\([^?#]*\)\(?\([^#]*\)\)\{0,1\}\(#\(.*\)\)\{0,1\}$'
ipPattern='^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'
tmpFile=$(mktemp)
listitem=''
headerField=''

for value in ${blacklist:+"cookie_reject_domains ${blacklist}"} ${whitelist:+"cookie_accept_domains ${whitelist}"}; do
	name="${value% *}"
	action="${value#* }"
	field=$(sed -n -e "/^${name}[	 ]/{p; q}" -- "${config}")

	if [ -z "${field}" ]; then
		value=''
		printf '%s \n' "${field}" >>"${config}"
	else
		value=$(printf '%s,' "${field}" | sed -e "s/^${name}//; s/[	 ,]\\{1,\\}/,/" | tr 'A-Z' 'a-z')
	fi

	for domain in ${@+"${@}"}; do
		if [ "${domain}" != "${domain#*/}" ]; then
			domain=$(printf '%s' "${domain}" | sed -e "s/${uriPattern}/\\5/")
		fi

		if [ -z "${domain}" ]; then
			continue
		fi

		if [ "${subdomain}" -eq 1 ] && printf '%s' "${domain}" | grep -Eqv -e "${ipPattern}"; then
			domain=".${domain}"
		fi

		case "${value}" in
			*",${domain},"*)
				case "${action}" in 'delete' | 'toggle')
					value=$(printf '%s' "${value}" | fsed ",${domain}" '')
					listitem="${listitem}<li>Removed the '<strong>${domain}</strong>' from the '<code>${name}</code>'.</li>"
					;;
				esac
				;;
			*)
				case "${action}" in 'add' | 'toggle')
					value="${value}${domain},"
					listitem="${listitem}<li>Added the '<strong>${domain}</strong>' to the '<code>${name}</code>'.</li>"
					;;
				esac
				;;
		esac
	done

	value="${value#,}"
	value="${value%,}"

	sed -e "/^${name}[	 ]/c ${name} ${value}" -- "${config}" >"${tmpFile}"
	cp -fp "${tmpFile}" "${config}"

	headerField=$(printf '%sW3m-control: SET_OPTION %s=%s\n$' "${headerField}" "${name}" "${value}")
	headerField="${headerField%$}"
done

printRedirect.sh --header-field "${headerField}" "data:text/html;base64,$("${W3MPLUS_TEMPLATE_HTML}" -t 'Cookie Manager' -c "<ul>${listitem}</ul>" | base64 | tr -d '\n')"
