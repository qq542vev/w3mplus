@include "uri_path_remove_dot_segments.awk"

function uri_path_parent(path, count) {
	path = uri_path_remove_dot_segments(path)
	gsub(/[/]+/, "/", path)

	for(; 1 <= count && path != "" && path != "/"; count--) {
		gsub(/[^/]*[/]?$/, "", path)
	}

	return path
}
