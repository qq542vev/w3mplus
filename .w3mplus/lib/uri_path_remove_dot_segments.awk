function uri_path_remove_dot_segments(path,  result) {
	if(!index(path, ".")) {
		return path
	}

	result = ""

	while(path != "") {
		if(index(path, "./") == 1) {
			path = substr(path, 3)
		} else if(index(path, "../") == 1) {
			path = substr(path, 4)
		} else if(index(path, "/./") == 1) {
			path = substr(path, 3)
		} else if(path == "/.") {
				path = "/"
		} else if(index(path, "/../") == 1) {
			path = substr(path, 4)
			gsub(/\/?[^\/]*$/, "", result)
		} else if(path == "/..") {
			path = "/"
			gsub(/\/?[^\/]*$/, "", result)
		} else if(path == "." || path == "..") {
			path = ""
		} else {
			match(path, /^.[^\/]*/)

			result = result substr(path, RSTART, RLENGTH)
			path = substr(path, RLENGTH + 1)
		}
	}

	return result
}
