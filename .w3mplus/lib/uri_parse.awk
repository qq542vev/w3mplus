function uri_parse(uri, element,  pattern,key,i,auth,result) {
	split("^[^:/?#]*: ^//[^/?#]* ^[^?#]* ^\\?[^#]* ^#.* ^[^@/?#]*@ ^[^:/?#]* ^:[^/?#]*", pattern, " ")
	split("scheme authority path query fragment userinfo host port", key, " ")
	split("", element)

	for(i = 1; i <= 5; i++) {
		element[key[i]] = ""

		if(match(uri, pattern[i])) {
			element[key[i]] = substr(uri, RSTART, RLENGTH)
			uri = substr(uri, RSTART + RLENGTH)
		}
	}

	element["userinfo"] = ""
	element["host"] = ""
	element["port"] = ""

	if(element["authority"]) {
		auth = substr(element["authority"], 3)

		for(i = 6; i <= 8; i++) {
			if(match(auth, pattern[i])) {
				element[key[i]] = substr(auth, RSTART, RLENGTH)
				auth = substr(auth, RSTART + RLENGTH)
			}
		}
	}
}
