function html_escape(string) {
	gsub(/&/, "\\&amp;", string)
	gsub(/</, "\\&lt;", string)
	gsub(/</, "\\&gt;", string)
	gsub(/'/, "\\&#39;", string)
	gsub(/"/, "\\&quot;", string)

	return string
}
