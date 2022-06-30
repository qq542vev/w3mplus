function regex_escape(string) {
	gsub(/[].\\*+?|(){}[^$]/, "\\\\&", string)

	return string
}

