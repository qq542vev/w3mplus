function url_encode(string, httpEncode,  c2p,len,i,result) {
	c2p["\000"] = "%00"; c2p["\001"] = "%01"; c2p["\002"] = "%02"; c2p["\003"] = "%03";
	c2p["\004"] = "%04"; c2p["\005"] = "%05"; c2p["\006"] = "%06"; c2p["\007"] = "%07";
	c2p["\010"] = "%08"; c2p["\011"] = "%09"; c2p["\012"] = "%0A"; c2p["\013"] = "%0B";
	c2p["\014"] = "%0C"; c2p["\015"] = "%0D"; c2p["\016"] = "%0E"; c2p["\017"] = "%0F";
	c2p["\020"] = "%10"; c2p["\021"] = "%11"; c2p["\022"] = "%12"; c2p["\023"] = "%13";
	c2p["\024"] = "%14"; c2p["\025"] = "%15"; c2p["\026"] = "%16"; c2p["\027"] = "%17";
	c2p["\030"] = "%18"; c2p["\031"] = "%19"; c2p["\032"] = "%1A"; c2p["\033"] = "%1B";
	c2p["\034"] = "%1C"; c2p["\035"] = "%1D"; c2p["\036"] = "%1E"; c2p["\037"] = "%1F";
	c2p["\040"] = "%20"; c2p["\041"] = "%21"; c2p["\042"] = "%22"; c2p["\043"] = "%23";
	c2p["\044"] = "%24"; c2p["\045"] = "%25"; c2p["\046"] = "%26"; c2p["\047"] = "%27";
	c2p["\050"] = "%28"; c2p["\051"] = "%29"; c2p["\052"] = "%2A"; c2p["\053"] = "%2B";
	c2p["\054"] = "%2C"; c2p["\055"] = "-"; c2p["\056"] = "."; c2p["\057"] = "%2F";
	c2p["\060"] = "0"; c2p["\061"] = "1"; c2p["\062"] = "2"; c2p["\063"] = "3";
	c2p["\064"] = "4"; c2p["\065"] = "5"; c2p["\066"] = "6"; c2p["\067"] = "7";
	c2p["\070"] = "8"; c2p["\071"] = "9"; c2p["\072"] = "%3A"; c2p["\073"] = "%3B";
	c2p["\074"] = "%3C"; c2p["\075"] = "%3D"; c2p["\076"] = "%3E"; c2p["\077"] = "%3F";
	c2p["\100"] = "%40"; c2p["\101"] = "A"; c2p["\102"] = "B"; c2p["\103"] = "C";
	c2p["\104"] = "D"; c2p["\105"] = "E"; c2p["\106"] = "F"; c2p["\107"] = "G";
	c2p["\110"] = "H"; c2p["\111"] = "I"; c2p["\112"] = "J"; c2p["\113"] = "K";
	c2p["\114"] = "L"; c2p["\115"] = "M"; c2p["\116"] = "N"; c2p["\117"] = "O";
	c2p["\120"] = "P"; c2p["\121"] = "Q"; c2p["\122"] = "R"; c2p["\123"] = "S";
	c2p["\124"] = "T"; c2p["\125"] = "U"; c2p["\126"] = "V"; c2p["\127"] = "W";
	c2p["\130"] = "X"; c2p["\131"] = "Y"; c2p["\132"] = "Z"; c2p["\133"] = "%5B";
	c2p["\134"] = "%5C"; c2p["\135"] = "%5D"; c2p["\136"] = "%5E"; c2p["\137"] = "_";
	c2p["\140"] = "%60"; c2p["\141"] = "a"; c2p["\142"] = "b"; c2p["\143"] = "c";
	c2p["\144"] = "d"; c2p["\145"] = "e"; c2p["\146"] = "f"; c2p["\147"] = "g";
	c2p["\150"] = "h"; c2p["\151"] = "i"; c2p["\152"] = "j"; c2p["\153"] = "k";
	c2p["\154"] = "l"; c2p["\155"] = "m"; c2p["\156"] = "n"; c2p["\157"] = "o";
	c2p["\160"] = "p"; c2p["\161"] = "q"; c2p["\162"] = "r"; c2p["\163"] = "s";
	c2p["\164"] = "t"; c2p["\165"] = "u"; c2p["\166"] = "v"; c2p["\167"] = "w";
	c2p["\170"] = "x"; c2p["\171"] = "y"; c2p["\172"] = "z"; c2p["\173"] = "%7B";
	c2p["\174"] = "%7C"; c2p["\175"] = "%7D"; c2p["\176"] = "~"; c2p["\177"] = "%7F";
	c2p["\200"] = "%80"; c2p["\201"] = "%81"; c2p["\202"] = "%82"; c2p["\203"] = "%83";
	c2p["\204"] = "%84"; c2p["\205"] = "%85"; c2p["\206"] = "%86"; c2p["\207"] = "%87";
	c2p["\210"] = "%88"; c2p["\211"] = "%89"; c2p["\212"] = "%8A"; c2p["\213"] = "%8B";
	c2p["\214"] = "%8C"; c2p["\215"] = "%8D"; c2p["\216"] = "%8E"; c2p["\217"] = "%8F";
	c2p["\220"] = "%90"; c2p["\221"] = "%91"; c2p["\222"] = "%92"; c2p["\223"] = "%93";
	c2p["\224"] = "%94"; c2p["\225"] = "%95"; c2p["\226"] = "%96"; c2p["\227"] = "%97";
	c2p["\230"] = "%98"; c2p["\231"] = "%99"; c2p["\232"] = "%9A"; c2p["\233"] = "%9B";
	c2p["\234"] = "%9C"; c2p["\235"] = "%9D"; c2p["\236"] = "%9E"; c2p["\237"] = "%9F";
	c2p["\240"] = "%A0"; c2p["\241"] = "%A1"; c2p["\242"] = "%A2"; c2p["\243"] = "%A3";
	c2p["\244"] = "%A4"; c2p["\245"] = "%A5"; c2p["\246"] = "%A6"; c2p["\247"] = "%A7";
	c2p["\250"] = "%A8"; c2p["\251"] = "%A9"; c2p["\252"] = "%AA"; c2p["\253"] = "%AB";
	c2p["\254"] = "%AC"; c2p["\255"] = "%AD"; c2p["\256"] = "%AE"; c2p["\257"] = "%AF";
	c2p["\260"] = "%B0"; c2p["\261"] = "%B1"; c2p["\262"] = "%B2"; c2p["\263"] = "%B3";
	c2p["\264"] = "%B4"; c2p["\265"] = "%B5"; c2p["\266"] = "%B6"; c2p["\267"] = "%B7";
	c2p["\270"] = "%B8"; c2p["\271"] = "%B9"; c2p["\272"] = "%BA"; c2p["\273"] = "%BB";
	c2p["\274"] = "%BC"; c2p["\275"] = "%BD"; c2p["\276"] = "%BE"; c2p["\277"] = "%BF";
	c2p["\300"] = "%C0"; c2p["\301"] = "%C1"; c2p["\302"] = "%C2"; c2p["\303"] = "%C3";
	c2p["\304"] = "%C4"; c2p["\305"] = "%C5"; c2p["\306"] = "%C6"; c2p["\307"] = "%C7";
	c2p["\310"] = "%C8"; c2p["\311"] = "%C9"; c2p["\312"] = "%CA"; c2p["\313"] = "%CB";
	c2p["\314"] = "%CC"; c2p["\315"] = "%CD"; c2p["\316"] = "%CE"; c2p["\317"] = "%CF";
	c2p["\320"] = "%D0"; c2p["\321"] = "%D1"; c2p["\322"] = "%D2"; c2p["\323"] = "%D3";
	c2p["\324"] = "%D4"; c2p["\325"] = "%D5"; c2p["\326"] = "%D6"; c2p["\327"] = "%D7";
	c2p["\330"] = "%D8"; c2p["\331"] = "%D9"; c2p["\332"] = "%DA"; c2p["\333"] = "%DB";
	c2p["\334"] = "%DC"; c2p["\335"] = "%DD"; c2p["\336"] = "%DE"; c2p["\337"] = "%DF";
	c2p["\340"] = "%E0"; c2p["\341"] = "%E1"; c2p["\342"] = "%E2"; c2p["\343"] = "%E3";
	c2p["\344"] = "%E4"; c2p["\345"] = "%E5"; c2p["\346"] = "%E6"; c2p["\347"] = "%E7";
	c2p["\350"] = "%E8"; c2p["\351"] = "%E9"; c2p["\352"] = "%EA"; c2p["\353"] = "%EB";
	c2p["\354"] = "%EC"; c2p["\355"] = "%ED"; c2p["\356"] = "%EE"; c2p["\357"] = "%EF";
	c2p["\360"] = "%F0"; c2p["\361"] = "%F1"; c2p["\362"] = "%F2"; c2p["\363"] = "%F3";
	c2p["\364"] = "%F4"; c2p["\365"] = "%F5"; c2p["\366"] = "%F6"; c2p["\367"] = "%F7";
	c2p["\370"] = "%F8"; c2p["\371"] = "%F9"; c2p["\372"] = "%FA"; c2p["\373"] = "%FB";
	c2p["\374"] = "%FC"; c2p["\375"] = "%FD"; c2p["\376"] = "%FE"; c2p["\377"] = "%FF";

	if(httpEncode) {
		c2p[" "] = "+"
	}

	len = length(string)
	for(i = 1; i <= len; i++) {
		result = result c2p[substr(string, i, 1)]
	}

	return result
}
