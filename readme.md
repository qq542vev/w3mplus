<!--
### Document: readme.md
##
## w3mplus のマニュアル
##
## Metadata:
##
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 0.1.0
##   date - 2022-07-26
##   since - 2019-12-26
##   copyright - Copyright (C) 2019 - 2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - w3mplus
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/w3mplus>
##   * <Bag report at https://github.com/qq542vev/w3mplus>
-->

# w3mplus

w3mplus はテキストブラウザー w3m の拡張機能です。ほぼ全て ShellScript と AWK で作成しております。

w3mplus は [PaleMoon](https://www.palemoon.org/) + [Pentadactyl](https://github.com/pentadactyl/pentadactyl) の機能を徹底的に模倣しています。主に以下のような機能を利用できます。

 * PaleMoon の模倣
   * メニューバー
   * ロケーションバー
   * コンテキストメニュー
   * Denylist
   * その他細かなUI関連
 * Pentadactyl の模倣
   * `o`, `t`, `O`, `T`, `gh`, `gu` などのリソースへのアクセス 
   * `h`, `j`, `k`, `l`, `gg`, `G`, `0`, `$` などのページ内の移動
   * `y`, `Y` などのヤンク
   * `d`, `u` などのタブを閉じる、タブの復元
   * ヒント及び拡張ヒント
   * QuickMark & LocalMark
