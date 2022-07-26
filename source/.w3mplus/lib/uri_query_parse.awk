function uri_query_parse(string, result,  query,queryCount,i,position) {
	queryCount = split(string, query, "&")
	split("", result)

	for(i = 1; i <= queryCount; i++) {
		if(query[i] != "") {
			position = index(query[i], "=")

			if(position) {
				result[url_decode(substr(query[i], 1, position - 1), 1)] = url_decode(substr(query[i], position + 1), 1)
			} else {
				result[url_decode(query[i], 1)] = ""
			}
		}
	}
}
