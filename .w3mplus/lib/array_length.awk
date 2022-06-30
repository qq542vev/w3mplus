function array_length(array,  count,key) {
	count = 0

	for(key in array) {
		count++
	}

	return count
}
