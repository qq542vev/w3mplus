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
