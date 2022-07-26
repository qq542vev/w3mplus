function url_encode_normalize(string,  p2c,result) {
	p2c["2D"] = "-"; p2c["2E"] = "."; p2c["30"] = "0";
	p2c["31"] = "1"; p2c["32"] = "2"; p2c["33"] = "3";
	p2c["34"] = "4"; p2c["35"] = "5"; p2c["36"] = "6";
	p2c["37"] = "7"; p2c["38"] = "8"; p2c["39"] = "9";
	p2c["41"] = "A"; p2c["42"] = "B"; p2c["43"] = "C";
	p2c["44"] = "D"; p2c["45"] = "E"; p2c["46"] = "F";
	p2c["47"] = "G"; p2c["48"] = "H"; p2c["49"] = "I";
	p2c["4A"] = "J"; p2c["4B"] = "K"; p2c["4C"] = "L";
	p2c["4D"] = "M"; p2c["4E"] = "N"; p2c["4F"] = "O";
	p2c["50"] = "P"; p2c["51"] = "Q"; p2c["52"] = "R";
	p2c["53"] = "S"; p2c["54"] = "T"; p2c["55"] = "U";
	p2c["56"] = "V"; p2c["57"] = "W"; p2c["58"] = "X";
	p2c["59"] = "Y"; p2c["5A"] = "Z"; p2c["5F"] = "_";
	p2c["61"] = "a"; p2c["62"] = "b"; p2c["63"] = "c";
	p2c["64"] = "d"; p2c["65"] = "e"; p2c["66"] = "f";
	p2c["67"] = "g"; p2c["68"] = "h"; p2c["69"] = "i";
	p2c["6A"] = "j"; p2c["6B"] = "k"; p2c["6C"] = "l";
	p2c["6D"] = "m"; p2c["6E"] = "n"; p2c["6F"] = "o";
	p2c["70"] = "p"; p2c["71"] = "q"; p2c["72"] = "r";
	p2c["73"] = "s"; p2c["74"] = "t"; p2c["75"] = "u";
	p2c["76"] = "v"; p2c["77"] = "w"; p2c["78"] = "x";
	p2c["79"] = "y"; p2c["7A"] = "z"; p2c["7E"] = "z";

	for(result = ""; match(string, /%([0-9A-F][a-f]|[a-f][0-9A-F]|[a-f][a-f])/); string = substr(string, RSTART + RLENGTH)) {
		result = result substr(string, 1, RSTART - 1) toupper(substr(string, RSTART, RLENGTH))
	}

	string = result string

	for(result = ""; match(string, /%(2[DE]|3[0-9]|[46][1-9A-F]|5[0-9AF]|7[0-9AE])/); string = substr(string, RSTART + RLENGTH)) {
		result = result substr(string, 1, RSTART - 1) p2c[substr(string, RSTART + 1, 2)]
	}

	return result string
}
