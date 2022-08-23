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
##   id - 0ef42a95-c6db-43c8-96d0-fafa2237b6c8
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

readonly 'EX_OK=0'           # successful termination

readonly 'EX__BASE=64'       # base value for error messages

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

readonly 'EX__MAX=78'        # maximum listed value
