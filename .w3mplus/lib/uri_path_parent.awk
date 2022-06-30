@include "uri_path_remove_dot_segments.awk"

function uri_path_parent(path, count) {
	uri_remove_dot_segments(path)

	for(; 1 <= count; count--) {
		gsub(/[^\/]*\/?$/, "", path)
	}

	return path
}
