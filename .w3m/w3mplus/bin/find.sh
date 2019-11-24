#!/usr/bin/env sh

##
# Search for a word.
#
# @author qq542vev
# @version 1.0.0
# @date 2019-11-20
# @licence https://creativecommons.org/licenses/by/4.0/
##

set -eu

# 各変数に既定値を代入する
command='SEARCH'
exactFlag='0'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-b' | '--back')
			command='SEARCH_BACK'
			shift
			;;
		'-e' | '--exact')
			exactFlag='1'
			shift
			;;
		# ヘルプメッセージを表示して終了する
		'-h' | '--help')
			cat <<- EOF
				Usage: ${0} [OPTION]... WORD [WORD]...
				Search for a word.

				 -b, --back   backward search
				 -e, --exact  exact search
				 -h, --help   display this help and exit
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
				args="${args}${args:+ }$(printf '%s' "${1}" | sed -e "s/./'&'/g; s/'''/\"'\"/g")"
				shift
			done
			;;
		# 複合ショートオプション
		'-'[!-][!-]*)
			option="${1}"
			shift
			# `-abc` を `-a -bc` に変換して再セットする
			set -- "-$(printf '%s' "${option}" | cut -c 2)" "-$(printf '%s' "${option}" | cut -c 3-)" ${@+"${@}"}
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
			args="${args}${args:+ }$(printf '%s' "${1}" | sed -e "s/./'&'/g; s/'''/\"'\"/g")"
			shift
			;;
	esac
done

# オプション以外の引数を再セットする
eval set -- "${args}"

# 引数の個数が過小である
if [ "${#}" -eq 0 ]; then
	cat <<- EOF 1>&2
		${0}: not enough arguments
		Try '${0} --help' for more information.
	EOF

	exit 64 # EX_USAGE </usr/include/sysexits.h>
fi

keyword=''

for word in ${@+"${@}"}; do
	if [ -n "${word}" ]; then
		keyword="${keyword}${keyword:+|}$(printf '%s' "${word}" | sed -e 's/[].\*+?|(){}[]/\\&/g; 1s/^^/\\^/; $s/$$/\\$/')
"
	fi
done

if [ -n "${keyword}" ]; then
	if [ "${exactFlag}" -eq 1 ]; then
		keyword="(^|[	 ])${keyword}([	 ]|\$)"
	fi

	printf 'W3m-control: %s %s' "${command}" "${keyword}"
fi | httpResponseW3mBack.sh -
