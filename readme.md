<!--
### Document: readme.md
##
## w3mplus のマニュアル
##
## Metadata:
##
##   id - 7539cc1d-6b5f-44e5-baf7-a66b22b2213f
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 0.2.0
##   date - 2022-08-31
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

w3mplus はテキストブラウザー w3m の拡張機能です。ほぼ全ての機能を POSIX 準拠の ShellScript と AWK で作成しております。

w3mplus は [PaleMoon](https://www.palemoon.org/) + [Pentadactyl](https://github.com/pentadactyl/pentadactyl) の機能を徹底的に模倣しています。主に以下のような機能を利用できます。

 * Pale Moon の模倣
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
   * クイッマーク、ローカルマーク、URL マーク
   * レジスタ

# インストール

w3mplus を利用するには POSIX 準拠の Shell 環境と AWK が必要です。mawk は拡張正規表現を完全に実装していない、正規表現の長さに制限があるなどの理由で現状利用できません。よって GAWK をお勧めします。また `awk` コマンドで POSIX 準拠の AWK が起動する環境が必要です。

[Releases ページ](https://github.com/qq542vev/w3mplus/releases)から最新バージョンをダウンロードして、解凍します。release/install.sh を実行すればインストール完了です。

# 使い方

インストール後の `.w3mplus/doc/index.html` にマニュアルがあります。
