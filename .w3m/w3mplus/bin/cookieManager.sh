#!/usr/bin/env sh

##
# Cookie management.
#
# @author qq542vev
# @version 1.0.2
# @date 2020-02-08
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
				${0##*/} (w3mplus) $(sed -n -e 's/^# @version //1p' -- "${0}") (Last update: $(sed -n -e 's/^# @date //1p' -- "${0}"))
				$(sed -n -e 's/^# @copyright //1p' -- "${0}")
				License: $(sed -n -e 's/^# @licence //1p' -- "${0}")
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

# オプション以外の引数を再セットする
eval set -- "${args}"

if [ "${#}" -eq 0 ]; then
	set -f
	set -- $(cat)
	set +f
fi

tmpFile=$(mktemp)
listitem=''

for value in ${blacklist:+"cookie_reject_domains ${blacklist}"} ${whitelist:+"cookie_accept_domains ${whitelist}"}; do
	field="${value% *}"
	action="${value#* }"
	item=$(sed -n -e "s/^${field}[\\t ]//p" -- "${config}" | sed -e 's/[\t ,]\{1,\}/,/g; s/^,//; s/,$//' | tr 'A-Z' 'a-z')

	for domain in ${@+"${@}"}; do
		if [ "${domain}" != "${domain#*/}" ]; then
			domain=$(printf '%s' "${domain}" | sed -E -e 's/^(([^:/?#]+):)?(\/\/([^@/?#]@)?([^/?#]*)(:[^/?#]*)?)?([^?#]*)(\?([^#]*))?(#(.*))?$/\5/')
		fi

		if [ -z "${domain}" ]; then
			continue
		fi

		if [ "${subdomain}" -eq 1 ] && printf '%s' "${domain}" | grep -Eqv -e '^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'; then
			domain=".${domain}"
		fi

		escaped=$(printf '%s' "${domain}" | tr 'A-Z' 'a-z' | sed -e 's/[].\*/[]/\\&/g; 1s/^^/\\^/; s/$$/\\$/')

		if printf '%s' "${item}" | grep -E -e "(^|,)${escaped}(,|\$)"; then
			case "${action}" in 'delete' | 'toggle')
				item=$(printf '%s' "${item}" | sed -e "s/^${escaped},\\{0,1\\}//g; s/,${escaped}//g")
				listitem="${listitem}<li>Removed the '<strong>${domain}</strong>' from the '<code>${field}</code>'.</li>"
			esac
		else
			case "${action}" in 'add' | 'toggle')
				item="${item}${item:+,}${domain}"
				listitem="${listitem}<li>Added the '<strong>${domain}</strong>' to the '<code>${field}</code>'.</li>"
			esac
		fi
	done

	sed -e "/^${field}[\\t ]/c ${field} ${item}" -- "${config}" >"${tmpFile}"
	cp -fp "${tmpFile}" "${config}"
done

printf '<ul>%s</ul>' "${listitem}" | printHtml.sh --title 'Cookie Manager'
