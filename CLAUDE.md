# CLAUDE.md

## このリポジトリについて

**pop-shelf** iOS アプリ用のデータリポジトリです。POP MART ブラインドボックスフィギュアのトラッカーアプリ向けに、静的 JSON ファイルと画像を GitHub Pages (`https://shimai0913.github.io/pop-shelf-data/`) で配信しています。コンパニオンアプリは `../pop-shelf/pop-shelf/Resources/` にあり、これらの JSON ファイルを直接参照します。

## よく使うコマンド

新シリーズ追加時は以下の順で実行します。

```bash
# 1. POPMART JP サイトマップから新シリーズを取得 → generated/ にファイルを生成
python3 fetch_series.py
# → 下書きを確認し、新しいシリーズエントリをルートの {ip-id}.json にコピー
# → index.json の seriesCount を手動で更新

# 2. シリーズのサムネイル画像をスクレイピング（TARGET_IPS リストに含まれる IP のみ）
cd scripts && node scrape-series-images.js

# 3. ルートの JSON ファイルを iOS アプリの Resources ディレクトリに同期
./sync-to-app.sh            # 全 IP
./sync-to-app.sh molly      # 特定の IP のみ
```

## データアーキテクチャ

### JSON スキーマ

**`index.json`** — アプリのホーム画面が参照するマスター IP リスト:
```json
{ "version": "1.0.0", "updatedAt": "YYYY-MM-DD",
  "ips": [{ "id", "name", "thumbnailUrl", "totalCount", "seriesCount" }] }
```

**`{ip-id}.json`** — IP ごとのシリーズ・キャラクターデータ:
```json
{ "id", "name", "designer", "updatedAt",
  "series": [{
    "id", "name", "type", "releaseYear", "releaseDate", "imageUrl",
    "characters": [{ "id", "name", "slot", "isSecret", "imageUrl", "description", "tags", "purchaseUrl" }]
  }]
}
```

- `series.id` はケバブケース: `{ip-id}-{series-slug}`（`fetch_series.py` 内の `to_series_id()` で生成）
- `imageUrl` フィールドは GitHub Pages のベース URL を使用: `https://shimai0913.github.io/pop-shelf-data/images/...`
- `index.json` の `totalCount` は常に `0` — 所持数はアプリの SwiftData レイヤーで管理され、このリポジトリには書き戻されません。
- `index.json` の `seriesCount` は**自動計算されません** — IP ファイルにシリーズを追加・削除した際は手動で更新してください。

### 画像の命名規則

- `images/{ip-id}.webp` — IP レベルのサムネイル（IP ごとに 1 枚、ホーム画面で使用）
- `images/series/{series-id}.webp` — `scrape-series-images.js` でダウンロードするシリーズごとのサムネイル

すべての画像は `.webp` 形式にしてください。ファイル名のステムには JSON の `id` 値をそのまま使用します。

### ファイル構成

- **ルートの `*.json`** — プロダクション用データファイル（iOS アプリが GitHub Pages 経由で読み込む）
- **`generated/`** — `fetch_series.py` の下書き出力先; gitignore 対象、コミットしない

### シリーズ画像スクレイパーの詳細

`scripts/scrape-series-images.js` は `TARGET_IPS` 配列に含まれる IP のみを処理します。サイトマップから自動マッチできないシリーズは、スクリプト冒頭の `MANUAL_URL_OVERRIDES` に商品 URL を追加してください。

## コンパニオンアプリとの連携

アプリは実行時に GitHub Pages から JSON を読み込み、オフライン時はバンドルされた `Resources/` コピーにフォールバックします。

- **新しい IP をアプリに追加する**（UI エントリを含む）場合は、`pop-shelf` リポジトリの Claude Code セッション内で `/add-ip` スキルを使用してください — データ側の JSON スキャフォールディングとアプリ側の配線を一括で処理します。
