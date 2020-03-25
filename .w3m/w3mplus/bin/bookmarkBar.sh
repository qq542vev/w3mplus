#!/usr/bin/env sh

## File: bookmarkBar.sh
##
## Displays a page about w3m.
##
## Usage:
##
##   (start code)
##   bookmarkBar.sh [OPTION]...
##   (end)
##
## Options:
##
## Exit Status:
##
##   0 - Program terminated normally.
##   64<= and <=78 - Program terminated abnormally. See </usr/include/sysexits.h> for the returned value.
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.2
##   date - 2020-03-26
##   since - 2020-02-26
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

# initファイルの読み込み
: "${W3MPLUS_PATH:=${HOME}/.w3m/w3mplus}"
. "${W3MPLUS_PATH}/lib/w3mplus/init"

sidebar () (
	printf '<frame name="menu" title="Bookmark Menu" src="data:text/html;base64,%s" />\n' "$(sed -e 's/<a /<a target="main" /' "${1}" | base64 | tr -d '\n')"
)

toolbar () (
		links=$(sed -e '/<h2>Bookmarks Toolbar<\/h2>/,/<\/ul>/!d; /<li>/!d; s/<\/\{0,1\}li>//g; s/<a /<a target="main"/' "${file}" | sed -e '1!s/^/| /')
		printf '<frame name="toolbar" title="Bookmark Toolbar" src="data:text/html;base64,%s" />' "$(${W3MPLUS_TEMPLATE_HTML} -t 'Bookmark' -c "<p>${links}</p>" | base64 | tr -d '\n')"
)

# 各変数に既定値を代入する
file="${HOME}/.w3m/bookmark.html"
size='35'
type='leftSidebar'
uri='data:text/plain,'
args=''

# コマンドライン引数の解析する
while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-f' | '--file')
			file="${2}"
			shift 2
			;;
		'-s' | '--size')
			if expr -- "${2}" ':' '[1-9][0-9]*$' >'/dev/null'; then
				size="${2}"
				shift 2
			else
				printf 'The option "%s" must be a integer.\n' "${1}" 1>&2
				exitStatus="${EX_USAGE}"; exit
			fi
			;;
		'-t' | '--type')
			case "${2}" in
				'leftSidebar'| 'rightSidebar' | 'topToolbar' | 'bottomToolbar')
					type="${2}"
					shift 2
					;;
				*)
					printf "'The option '%s' must be a 'sidebar' or 'toolbar'.\n" "${1}" 1>&2
					exitStatus="${EX_USAGE}"; exit
					;;
			esac
			;;
		'-u' | '--uri')
			uri="${2}"
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
			args="${args}$(quoteEscape ${@+"${@}"})"
			shift "${#}"
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
			args="${args}$(quoteEscape "${1}")"
			shift
			;;
	esac
done

# オプション以外の引数を再セットする
eval set -- "${args}"

pattern='^pixel_per_char[	 ]\{1,\}\([0-9]\{1,\}\)[	 ]*$'
pixelPerChar=$(sed -n -e "/${pattern}/{s/${pattern}/\\1/p; q}" -- "${W3MPLUS_W3M_CONFIG}")

case "${pixelPerChar}" in '')
	pixelPerChar='6'
	;;
esac

col=$((size * pixelPerChar))
main="<frame name=\"main\" title=\"Main Content\" src=\"$(printf '%s' "${uri}" | htmlescape)\" />"

case "${type}" in
	'leftSidebar')
		menu=$(sidebar "${file}")
		attribute="cols=\"${col},*\""
		frames="${menu}${main}"
		;;
	'rightSidebar')
		menu=$(sidebar "${file}")
		attribute="cols=\"*,${col}\""
		frames="${main}${menu}"
		;;
	'topToolbar')
		menu=$(toolbar "${file}")
		attribute="rows=\"*,*\""
		frames="${menu}${main}"
		;;
	'bottomToolbar')
		menu=$(toolbar "${file}")
		attribute="rows=\"*,*\""
		frames="${main}${menu}"
		;;
esac

: | printHtml.sh --html-template "${W3MPLUS_TEMPLATE_FRAMESET}" --http-template '' --header-field "$(
	cat <<- 'EOF'
		W3m-control: SET_OPTION frame=1
		W3m-control: SET_OPTION target_self=1
	EOF
)" --title 'Bookmark' --meta-data "$(
	cat <<- EOF
	<frameset ${attribute}>
		${frames}
		<noframes>
			<p>The frame cannot be displayed on your Web browser.</p>

			<p>Please enable HTML Frame. If w3m, execute 'FRAME' command.</p>
		</noframes>
	</frameset>
	EOF
)"
