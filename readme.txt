# w3mplus

w3mplusはテキストブラウザーw3mの拡張機能です。ほぼ全てShellScriptで書かれています。

w3mplusは[PaleMoon](https://www.palemoon.org/) + [Pentadactyl](https://github.com/pentadactyl/pentadactyl)の機能を徹底的に模倣しています。主に以下のような機能を利用できます。

 * PaleMoonの模倣
     * メニューバー
     * ロケーションバー
     * コンテキストメニュー
     * HSTS Preload
     * Blacklist
     * その他細かなUI関連
 * Pentadactylの模倣
     * `o`, `t`, `O`, `T`, `gh`, `gu`などのリソースへのアクセス 
     * `h`, `j`, `k`, `l`, `gg`, `G`, `0`, '$'などのページ内の移動
     * `y`, `Y`などのヤンク
     * `d`, `u`などのタブを閉じる、タブの復元
     * ヒント及び拡張ヒント
     * QuickMark & LocalMark
