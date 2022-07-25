function sysexits(code,  status) {
	if(code == "EX_OK") {
		status = 0
	} else if(code == "EX_USAGE") {
		status = 64
	} else if(code == "EX_DATAERR") {
		status = 65
	} else if(code == "EX_NOINPUT") {
		status = 66
	} else if(code == "EX_NOUSER") {
		status = 67
	} else if(code == "EX_NOHOST") {
		status = 68
	} else if(code == "EX_UNAVAILABLE") {
		status = 69
	} else if(code == "EX_SOFTWARE") {
		status = 70
	} else if(code == "EX_OSERR") {
		status = 71
	} else if(code == "EX_OSFILE") {
		status = 72
	} else if(code == "EX_CANTCREAT") {
		status = 73
	} else if(code == "EX_IOERR") {
		status = 74
	} else if(code == "EX_TEMPFAIL") {
		status = 75
	} else if(code == "EX_PROTOCOL") {
		status = 76
	} else if(code == "EX_NOPERM") {
		status = 77
	} else if(code == "EX_CONFIG") {
		status = 78
	} else {
		status = 1
	}

	return status
}
