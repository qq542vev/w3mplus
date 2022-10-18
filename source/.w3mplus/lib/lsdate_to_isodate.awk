#!/usr/bin/awk -f

### Script: lsdate_to_isodate.awk
##
## ls コマンドで出力された日付を変換する関数を定義する。
##
## Usage:
##
## ------ Text ------
## awk -f 'lsdate_to_isodate.awk'
## ------------------
##
## ------ Text ------
## @include "lsdate_to_isodate.awk"
## ------------------
##
## Metadata:
##
##   id - 70f15f46-bf8e-41ec-b7ae-74f26993a897
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-10-18
##   since - 2022-10-18
##   copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bug report at https://github.com/qq542vev/w3mplus/issues>

### Function: lsdate_to_isodate
##
## ls コマンドで出力された日付を ISO 8601 の形式に変換する。
##
## Parameters:
##
##   month - ls コマンドで出力された月。
##   day - ls コマンドで出力された日。
##   year - ls コマンドで出力された年または時間。
##   currentYear - 現在の年。
##   currentMonth - 現在の月。
##
## Returns:
##
##   ISO 8601 に変換された日付文字列。

function lsdate_to_isodate(month, day, year, currentYear, currentMonth,  months) {
	split("", months)

	months["Jan"] = 1; months["Feb"] = 2; months["Mar"] = 3;
	months["Apr"] = 4; months["May"] = 5; months["Jun"] = 6;
	months["Jul"] = 7; months["Aug"] = 8; months["Sep"] = 9;
	months["Oct"] = 10; months["Nov"] = 11; months["Dec"] = 12;

	if(currentYear == "") {
		"date -- '+%Y'" | getline currentYear
		close("date -- '+%Y'")
	}

	if(currentMonth == "") {
		"date -- '+%m'" | getline currentMonth
		close("date -- '+%m'")
	}

	if(index(year, ":")) {
		return sprintf("%04d-%02d-%02dT%s", currentYear - (currentMonth < months[month]), months[month], day, year)
	}

	return sprintf("%04d-%02d-%02d", year, months[month], day)
}
