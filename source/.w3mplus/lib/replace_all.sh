#!/usr/bin/env sh

### Script: replace_all.sh
##
## w3m のためのレスポンスを表示する。
##
## Metadata:
##
##   id - b9583a4a-8da3-4527-8e49-31ce2dd5252a
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-09-10
##   since - 2022-09-10
##   copyright - Public Domain.
##   license - <CC0 at https://creativecommons.org/publicdomain/zero/1.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bag report at https://github.com/qq542vev/w3mplus/issues>
##   * <シェルスクリプトで文字列を置換するreplace_all関数を作りました（実はコーディングスタイルの解説） at https://qiita.com/ko1nksm/items/f2a41ee309dcd3b82e41>

# $1: ret, $2: value, $3: from, $4: to
replace_all_fast() {
  eval "$1=\${2//\"\$3\"/\"\$4\"}"
}

# $1: ret, $2: value, $3: from, $4: to
replace_all_posix() {
  set -- "$1" "$2" "$3" "$4" ""
  until [ _"$2" = _"${2#*"$3"}" ] && eval "$1=\$5\$2"; do
    set -- "$1" "${2#*"$3"}" "$3" "$4" "$5${2%%"$3"*}$4"
  done
}

# $1: ret, $2: value, $3: from, $4: to
replace_all_pattern() {
  set -- "$1" "$2" "$3" "$4" ""
  until eval "[ _\"\$2\" = _\"\${2#*$3}\" ] && $1=\$5\$2"; do
    eval "set -- \"\$1\" \"\${2#*$3}\" \"\$3\" \"\$4\" \"\$5\${2%%$3*}\$4\""
  done
}

meta_escape() {
  # shellcheck disable=SC1003
  if [ "${1#*\?}" ]; then # posh <= 0.5.4
    set -- '\\\\:\\\\\\\\' '\\\[:[[]' '\\\?:[?]' '\\\*:[*]' '\\\$:[$]'
  elif [ "${2%%\\*}" ]; then # bosh = all (>= 20181007), busybox <= 1.22.0
    set -- '\\\\:\\\\\\\\' '\[:[[]' '\?:[?]' '\*:[*]' '\$:[$]'
  else # POSIX compliant
    set -- '\\:\\\\' '\[:[[]' '\?:[?]' '\*:[*]' '\$:[$]'
  fi

  set "$@" '\(:\\(' '\):\\)' '\|:\\|' '\":\\\"' '\`:\\\`' \
    '\{:\\{' '\}:\\}' "\\':\\\\'" '\&:\\&' '\=:\\=' '\>:\\>' "end"

  echo 'meta_escape() { set -- "$1" "$2" ""'
  until [ "$1" = "end" ] && shift && printf '%s\n' "$@"; do
    set -- "${1%:*}" "${1#*:}" "$@"
    set -- "$@" 'until [ _"$2" = _"${2#*'"$1"'}" ] && set -- "$1" "$3$2" ""; do'
    set -- "$@" '  set -- "$1" "${2#*'"$1"'}" "$3${2%%'"$1"'*}'"$2"'"'
    set -- "$@" 'done'
    shift 3
  done
  echo 'eval "$1=\"\$3\$2\""; }'
}
eval "$(meta_escape "a?" "\\")"

replace_all() {
  (eval 'v="*#*/" p="#*/"; [ "${v//"$p"/-}" = "*-" ]') 2>/dev/null && return 0
  [ "${1#"$2"}" = "a*b" ] && return 1 || return 2
}
eval 'replace_all "a*b" "a[*]" &&:' &&:
case $? in
  0) # Fast version (Not POSIX compliant)
    # ash(busybox)>=1.30.1, bash>=3.1.17, dash>=none, ksh>=93?, mksh>=54
    # yash>=2.30?, zsh>=3.1.9?, pdksh=none, posh=none, bosh=none
    replace_all() { replace_all_fast "$@"; }; ;;
  1) # POSIX version (POSIX compliant)
    # ash(busybox)>=1.1.3, bash>=2.05b, dash>=0.5.2, ksh>=93q, mksh>=40
    # yash>=2.30?, zsh>=3.1.9?, pdksh=none, posh=none, bosh=none
    replace_all() { replace_all_posix "$@"; }; ;;
  2) # Pattern version
    replace_all() {
      meta_escape "$1" "$3"
      eval "replace_all_pattern \"\$1\" \"\$2\" \"\${$1}\" \"\$4\""
    }
esac

replace_multiple() {
	eval "${1}=\"\${2}\""
	eval "shift 2; set -- '${1}' \"\${@}\""

	while [ 2 -le "${#}" ]; do
		eval "replace_all '${1}' \"\${${1}}\" \"\${2}\" \"\${3-}\""
		eval "shift 2; set -- '${1}' \"\${@}\""
	done
}
