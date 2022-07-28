#!/usr/bin/env sh

### Script: install
##
## w3mplus をインストールする。
##
## Metadata:
##
##	 author - qq542vev <https://purl.org/meta/me/>
##	 version - 0.1.0
##	 date - 2022-07-27
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

set -efu
umask '0022'
LC_ALL='C'
IFS=$(printf ' \t\n_')
IFS="${IFS%_}"
PATH="${PATH-}${PATH:+:}$(command -p getconf 'PATH')"
UNIX_STD='2003'         # HP-UX POSIX mode
XPG_SUS_ENV='ON'        # AIX POSIX mode
XPG_UNIX98='OFF'        # AIX UNIX 03 mode
POSIXLY_CORRECT='1'     # GNU Coreutils POSIX mode
COMMAND_MODE='unix2003' # macOS UNIX 03 mode
export 'IFS' 'LC_ALL' 'PATH' 'UNIX_STD' 'XPG_SUS_ENV' 'XPG_UNIX98' 'POSIXLY_CORRECT' 'COMMAND_MODE'

#!/usr/bin/env sh

### Script: sysexits.sh
##
## Exit status codes for system programs.
##
## This include file attempts to categorize possible error
## exit statuses for system programs, notably delivermail
## and the Berkeley network.
##
## Error numbers begin at EX__BASE to reduce the possibility of
## clashing with other exit statuses that random programs may
## already return.  The meaning of the codes is approximately
## as follows:
##
## EX_USAGE - The command was used incorrectly, e.g., with
##   the wrong number of arguments, a bad flag, a bad
##   syntax in a parameter, or whatever.
## EX_DATAERR - The input data was incorrect in some way.
##   This should only be used for user's data & not
##   system files.
## EX_NOINPUT - An input file (not a system file) did not
##   exist or was not readable.  This could also include
##   errors like "No message" to a mailer (if it cared
##   to catch it).
## EX_NOUSER - The user specified did not exist.  This might
##   be used for mail addresses or remote logins.
## EX_NOHOST - The host specified did not exist.  This is used
##   in mail addresses or network requests.
## EX_UNAVAILABLE - A service is unavailable.  This can occur
##   if a support program or file does not exist.  This
##   can also be used as a catchall message when something
##   you wanted to do doesn't work, but you don't know
##   why.
## EX_SOFTWARE - An internal software error has been detected.
##   This should be limited to non-operating system related
##   errors as possible.
## EX_OSERR - An operating system error has been detected.
##   This is intended to be used for such things as "cannot
##   fork", "cannot create pipe", or the like.  It includes
##   things like getuid returning a user that does not
##   exist in the passwd file.
## EX_OSFILE - Some system file (e.g., /etc/passwd, /etc/utmp,
##   etc.) does not exist, cannot be opened, or has some
##   sort of error (e.g., syntax error).
## EX_CANTCREAT - A (user specified) output file cannot be
##   created.
## EX_IOERR - An error occurred while doing I/O on some file.
## EX_TEMPFAIL - temporary failure, indicating something that
##   is not really an error.  In sendmail, this means
##   that a mailer (e.g.) could not create a connection,
##   and the request should be reattempted later.
## EX_PROTOCOL - the remote system returned something that
##   was "not possible" during a protocol exchange.
## EX_NOPERM - You did not have sufficient permission to
##   perform the operation.  This is not intended for
##   file system problems, which should use NOINPUT or
##   CANTCREAT, but rather for higher level permissions.
##
## metadata:
##
##   author - <qq542vev at https://purl.org/meta/me/>
##   date - 2020-03-05
##   version - 1.0.0
##   copyright - Copyright (c) 1987, 1993
##     The Regents of the University of California.  All rights reserved.
##   license - BSD-3-Clause
##   package - w3mplus
##   source - <sysexits.h at https://github.com/freebsd/freebsd/blob/master/include/sysexits.h>
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bag report at https://github.com/qq542vev/w3mplus/issues>

#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. Neither the name of the University nor the names of its contributors
#     may be used to endorse or promote products derived from this software
#     without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
#  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#  SUCH DAMAGE.

readonly 'EX_OK=0' # successful termination

readonly 'EX__BASE=64' # base value for error messages

readonly 'EX_USAGE=64'       # command line usage error
readonly 'EX_DATAERR=65'     # data format error
readonly 'EX_NOINPUT=66'     # cannot open input
readonly 'EX_NOUSER=67'      # addressee unknown
readonly 'EX_NOHOST=68'      # host name unknown
readonly 'EX_UNAVAILABLE=69' # service unavailable
readonly 'EX_SOFTWARE=70'    # internal software error
readonly 'EX_OSERR=71'       # system error (e.g., can't fork)
readonly 'EX_OSFILE=72'      # critical OS file missing
readonly 'EX_CANTCREAT=73'   # can't create (user) output file
readonly 'EX_IOERR=74'       # input/output error
readonly 'EX_TEMPFAIL=75'    # temp failure; user is invited to retry
readonly 'EX_PROTOCOL=76'    # remote error in protocol
readonly 'EX_NOPERM=77'      # permission denied
readonly 'EX_CONFIG=78'      # configuration error

readonly 'EX__MAX=78' # maximum listed value

trap 'case "${?}" in 0) endCall;; *) endCall "${EX_SOFTWARE}";; esac' 0 # EXIT
trap 'endCall 129' 1                                                    # SIGHUP
trap 'endCall 130' 2                                                    # SIGINT
trap 'endCall 131' 3                                                    # SIGQUIT
trap 'endCall 143' 15                                                   # SIGTERM

endCall() {
	trap '' 0 # EXIT
	rm -fr -- ${tmpDir:+"${tmpDir}"}
	exit "${1:-0}"
}
option_error() {
	printf '%s: %s\n' "${0##*/}" "${1}" >&2
	printf '%s\n' "詳細については '${0##*/} --help' を実行してください。" >&2

	endCall "${EX_USAGE}"
}
regex_match() {
	awk -- '
		BEGIN {
			for(i = 2; i < ARGC; i++) {
				if(ARGV[1] !~ ARGV[i]) {
					exit 1
				}
			}

			exit
		}
	' ${@+"${@}"} || return 1

	return 0
}

# @getoptions
parser_definition() {
	setup REST abbr:true error:optuon_error plus:true no:0 help:usage \
		-- 'Usage:' "  ${2##*/} [OPTION]..." \
		'' 'Options:'

	param destBin --dest-bin init:'destBin="${HOME}/bin"' var:PATH -- 'PATH に bin をインストールする'
	param destW3m --dest-w3m init:'destW3m="${HOME}/.w3m"' var:PATH -- 'PATH に .w3m をインストールする'
	param destW3mplus --dest-w3mplus init:'destW3mplus="${HOME}/.w3mplus"' var:PATH -- 'PATH に .w3mplus をインストールする'
	param pass -p --pass init:'pass=$(tr -dc "a-zA-Z0-9" <"/dev/urandom" | fold -w "32" | head -n "1")' validate:'regex_match "${OPTARG}" "^[0-9A-Za-z]*$"' var:ALPHANUM -- 'pass のための文字列を指定する'
	flag silentFlag -s --{no-}silent init:@no -- '処理中の表示を行わない'
	param sourceBin --source-bin init:'sourceBin=$(dirname -- "${0}"; printf "_"); sourceBin="${sourceBin%?_}/bin"' var:DIRECTORY -- 'インストールする bin を指定する'
	param sourceW3m --source-w3m init:'sourceW3m=$(dirname -- "${0}"; printf "_"); sourceW3m="${sourceW3m%?_}/.w3m"' var:DIRECTORY -- 'インストールする .w3m を指定する'
	param sourceW3mplus --source-w3mplus init:'sourceW3mplus=$(dirname -- "${0}"; printf "_"); sourceW3mplus="${sourceW3mplus%?_}/.w3mplus"' var:DIRECTORY -- 'インストールする .w3mplus を指定する'
	disp :usage -h --help -- 'このヘルプを表示して終了する'
	disp VERSION -v --version -- 'バージョン情報を表示して終了する'

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
# Generated by getoptions (BEGIN)
# URL: https://github.com/ko1nksm/getoptions (v3.3.0)
destBin="${HOME}/bin"
destW3m="${HOME}/.w3m"
destW3mplus="${HOME}/.w3mplus"
pass=$(tr -dc "a-zA-Z0-9" <"/dev/urandom" | fold -w "32" | head -n "1")
silentFlag='0'
sourceBin=$(
	dirname -- "${0}"
	printf "_"
)
sourceBin="${sourceBin%?_}/bin"
sourceW3m=$(
	dirname -- "${0}"
	printf "_"
)
sourceW3m="${sourceW3m%?_}/.w3m"
sourceW3mplus=$(
	dirname -- "${0}"
	printf "_"
)
sourceW3mplus="${sourceW3mplus%?_}/.w3mplus"
REST=''
parse() {
	OPTIND=$(($# + 1))
	while OPTARG= && [ $# -gt 0 ]; do
		set -- "${1%%\=*}" "${1#*\=}" "$@"
		while [ ${#1} -gt 2 ]; do
			case $1 in *[!a-zA-Z0-9_-]*) break ;; esac
			case '--dest-bin' in
			"$1")
				OPTARG=
				break
				;;
			$1*) OPTARG="$OPTARG --dest-bin" ;;
			esac
			case '--dest-w3m' in
			"$1")
				OPTARG=
				break
				;;
			$1*) OPTARG="$OPTARG --dest-w3m" ;;
			esac
			case '--dest-w3mplus' in
			"$1")
				OPTARG=
				break
				;;
			$1*) OPTARG="$OPTARG --dest-w3mplus" ;;
			esac
			case '--pass' in
			"$1")
				OPTARG=
				break
				;;
			$1*) OPTARG="$OPTARG --pass" ;;
			esac
			case '--silent' in
			"$1")
				OPTARG=
				break
				;;
			$1*) OPTARG="$OPTARG --silent" ;;
			esac
			case '--no-silent' in
			"$1")
				OPTARG=
				break
				;;
			$1*) OPTARG="$OPTARG --no-silent" ;;
			esac
			case '--source-bin' in
			"$1")
				OPTARG=
				break
				;;
			$1*) OPTARG="$OPTARG --source-bin" ;;
			esac
			case '--source-w3m' in
			"$1")
				OPTARG=
				break
				;;
			$1*) OPTARG="$OPTARG --source-w3m" ;;
			esac
			case '--source-w3mplus' in
			"$1")
				OPTARG=
				break
				;;
			$1*) OPTARG="$OPTARG --source-w3mplus" ;;
			esac
			case '--help' in
			"$1")
				OPTARG=
				break
				;;
			$1*) OPTARG="$OPTARG --help" ;;
			esac
			case '--version' in
			"$1")
				OPTARG=
				break
				;;
			$1*) OPTARG="$OPTARG --version" ;;
			esac
			break
		done
		case ${OPTARG# } in
		*\ *)
			eval "set -- $OPTARG $1 $OPTARG"
			OPTIND=$((($# + 1) / 2)) OPTARG=$1
			shift
			while [ $# -gt "$OPTIND" ]; do
				OPTARG="$OPTARG, $1"
				shift
			done
			set "Ambiguous option: $1 (could be $OPTARG)" ambiguous "$@"
			optuon_error "$@" >&2 || exit $?
			echo "$1" >&2
			exit 1
			;;
		?*)
			[ "$2" = "$3" ] || OPTARG="$OPTARG=$2"
			shift 3
			eval 'set -- "${OPTARG# }"' ${1+'"$@"'}
			OPTARG=
			;;
		*) shift 2 ;;
		esac
		case $1 in
		--?*=*)
			OPTARG=$1
			shift
			eval 'set -- "${OPTARG%%\=*}" "${OPTARG#*\=}"' ${1+'"$@"'}
			;;
		--no-* | --without-*) unset OPTARG ;;
		-[p]?*)
			OPTARG=$1
			shift
			eval 'set -- "${OPTARG%"${OPTARG#??}"}" "${OPTARG#??}"' ${1+'"$@"'}
			;;
		-[shv]?*)
			OPTARG=$1
			shift
			eval 'set -- "${OPTARG%"${OPTARG#??}"}" -"${OPTARG#??}"' ${1+'"$@"'}
			OPTARG=
			;;
		+*) unset OPTARG ;;
		esac
		case $1 in
		'--dest-bin')
			[ $# -le 1 ] && set "required" "$1" && break
			OPTARG=$2
			destBin="$OPTARG"
			shift
			;;
		'--dest-w3m')
			[ $# -le 1 ] && set "required" "$1" && break
			OPTARG=$2
			destW3m="$OPTARG"
			shift
			;;
		'--dest-w3mplus')
			[ $# -le 1 ] && set "required" "$1" && break
			OPTARG=$2
			destW3mplus="$OPTARG"
			shift
			;;
		'-p' | '--pass')
			[ $# -le 1 ] && set "required" "$1" && break
			OPTARG=$2
			regex_match "${OPTARG}" "^[0-9A-Za-z]*$" || {
				set -- regex_match:$? "$1" regex_match "${OPTARG}" "^[0-9A-Za-z]*$"
				break
			}
			pass="$OPTARG"
			shift
			;;
		'-s' | '--silent' | '--no-silent')
			[ "${OPTARG:-}" ] && OPTARG=${OPTARG#*\=} && set "noarg" "$1" && break
			eval '[ ${OPTARG+x} ] &&:' && OPTARG='1' || OPTARG='0'
			silentFlag="$OPTARG"
			;;
		'--source-bin')
			[ $# -le 1 ] && set "required" "$1" && break
			OPTARG=$2
			sourceBin="$OPTARG"
			shift
			;;
		'--source-w3m')
			[ $# -le 1 ] && set "required" "$1" && break
			OPTARG=$2
			sourceW3m="$OPTARG"
			shift
			;;
		'--source-w3mplus')
			[ $# -le 1 ] && set "required" "$1" && break
			OPTARG=$2
			sourceW3mplus="$OPTARG"
			shift
			;;
		'-h' | '--help')
			usage
			exit 0
			;;
		'-v' | '--version')
			echo "${VERSION}"
			exit 0
			;;
		--)
			shift
			while [ $# -gt 0 ]; do
				REST="${REST} \"\${$((OPTIND - $#))}\""
				shift
			done
			break
			;;
		[-+]?*)
			set "unknown" "$1"
			break
			;;
		*)
			REST="${REST} \"\${$((OPTIND - $#))}\""
			;;
		esac
		shift
	done
	[ $# -eq 0 ] && {
		OPTIND=1
		unset OPTARG
		return 0
	}
	case $1 in
	unknown) set "Unrecognized option: $2" "$@" ;;
	noarg) set "Does not allow an argument: $2" "$@" ;;
	required) set "Requires an argument: $2" "$@" ;;
	pattern:*) set "Does not match the pattern (${1#*:}): $2" "$@" ;;
	notcmd) set "Not a command: $2" "$@" ;;
	*) set "Validation error ($1): $2" "$@" ;;
	esac
	optuon_error "$@" >&2 || exit $?
	echo "$1" >&2
	exit 1
}
usage() {
	cat <<'GETOPTIONSHERE'
Usage:
  install.sh [OPTION]...

Options:
          --dest-bin PATH     PATH に bin をインストールする
          --dest-w3m PATH     PATH に .w3m をインストールする
          --dest-w3mplus PATH PATH に .w3mplus をインストールする
  -p,     --pass ALPHANUM     pass のための文字列を指定する
  -s,     --{no-}silent       処理中の表示を行わない
          --source-bin DIRECTORY 
                              インストールする bin を指定する
          --source-w3m DIRECTORY 
                              インストールする .w3m を指定する
          --source-w3mplus DIRECTORY 
                              インストールする .w3mplus を指定する
  -h,     --help              このヘルプを表示して終了する
  -v,     --version           バージョン情報を表示して終了する

Exit Status:
    0 - successful termination
   64 - command line usage error
   65 - data format error
   66 - cannot open input
   67 - addressee unknown
   68 - host name unknown
   69 - service unavailable
   70 - internal software error
   71 - system error (e.g., can't fork)
   72 - critical OS file missing
   73 - can't create (user) output file
   74 - input/output error
   75 - temp failure; user is invited to retry
   76 - remote error in protocol
   77 - permission denied
   78 - configuration error
  129 - received SIGHUP
  130 - received SIGINT
  131 - received SIGQUIT
  143 - received SIGTERM
GETOPTIONSHERE
}
# Generated by getoptions (END)
# @end

#eval "$(getoptions parser_definition parse "${0}")"
parse ${@+"${@}"}
eval "set -- ${REST}"

baseDir=$(
	dirname -- "${0}"
	printf '_'
)
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

	case "${silentFlag}" in
	'0') printf "'%s' を確認中...\\n" "${sourceDir}" >&2 ;;
	esac

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

case "${silentFlag}" in
'0') printf "'.w3m' のファイルを設定中...\\n" >&2 ;;
esac

find -- "${tmpDir}/.w3m" -type f -exec sh -c "${shellScript}" 'sh' "${pass}" '{}' '+'

for value in 'bin:destBin' '.w3m:destW3m' '.w3mplus:destW3mplus'; do
	eval "destDir=\"\${${value##*:}}\""

	case "${destDir}" in
	?*)
		(
			case "${silentFlag}" in
			'0') printf "'%s' を '%s' にインストール中...\\n" "${value%%:*}" "${destDir}" >&2 ;;
			esac

			if [ '!' -e "${destDir}" ]; then
				mkdir -p -- "${destDir}"

				rm -fr "${destDir}"

				cp -R -- '.' "${destDir}"
			elif [ -d "${destDir}" ]; then
				mkdir -p -- "${destDir}"

				find -- "${tmpDir}/${value%%:*}/" -path '*[!/]' -prune -exec cp -fR -- '{}' "${destDir}" ';'
			else
				cat <<-EOF >&2
					${0##*/}: '${destDir}' はディレクトリではありません。
					詳細については '${0##*/} --help' を実行してください。
				EOF

				endCall "${EX_DATAERR}"
			fi
		)
		;;
	esac
done

case "${silentFlag}" in
'0') printf 'インストール完了\n' >&2 ;;
esac
