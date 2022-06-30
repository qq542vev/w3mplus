@include "array_length.awk"

function array_print(array, start, end, separator, format,  result) {
	if(start == "") {
		start = 1
	}

	if(end == "") {
		end = array_length(array)
	}

	if(format == "") {
		format = "%s"
	}

	for(result = ""; start <= end; start++) {
		if(start in array) {
			result = result separator sprintf(format, array[start])
		}
	}

	return substr(result, length(separator) + 1)
}
