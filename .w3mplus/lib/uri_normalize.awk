@include "url_encode_normalize.awk"
@include "uri_path_remove_dot_segments.awk"

function uri_normalize(uri,  element) {
	uri_parse(url_encode_normalize(uri), element)
	element["path"] = uri_path_remove_dot_segments(element["path"])

	return element["scheme"] element["authority"] element["path"] element["query"] element["fragment"]
}
