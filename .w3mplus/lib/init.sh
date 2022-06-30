set -efu
umask '0022'
LC_ALL='C'
IFS=$(printf ' \t\n_'); IFS="${IFS%_}"
PATH="${PATH-}${PATH:+:}$(command -p getconf 'PATH')"
UNIX_STD='2003' # HP-UX POSIX mode
XPG_SUS_ENV='ON' # AIX POSIX mode
XPG_UNIX98='OFF' # AIX UNIX 03 mode
POSIXLY_CORRECT='1' # GNU Coreutils POSIX mode
COMMAND_MODE='unix2003' # macOS UNIX 03 mode
export 'IFS' 'LC_ALL' 'PATH' 'UNIX_STD' 'XPG_SUS_ENV' 'XPG_UNIX98' 'POSIXLY_CORRECT' 'COMMAND_MODE'

trap 'case "${?}" in 0) endCall;; *) endCall "${EX_SOFTWARE}";; esac' 0 # EXIT
trap 'endCall 129' 1  # SIGHUP
trap 'endCall 130' 2  # SIGINT
trap 'endCall 131' 3  # SIGQUIT
trap 'endCall 143' 15 # SIGTERM

endCall() {
	trap '' 0 # EXIT
	rm -fr -- ${tmpDir:+"${tmpDir}"}
	exit "${1:-0}"
}

awk() {
	unset 'POSIXLY_CORRECT'
	gawk ${@+"${@}"}
}
