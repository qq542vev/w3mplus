function singlequote_escape(string) {
	gsub(/'+/, "'\"&\"'", string)

	return string
}
