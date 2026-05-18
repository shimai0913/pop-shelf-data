#!/bin/bash
# pop-shelf-data の IP JSONを アプリの Resources/ にコピーする
# Usage: ./sync-to-app.sh [ip-id]  # 省略時は全ファイル

APP_RESOURCES="/Users/shimai/workspace/pop-shelf/pop-shelf/Resources"
DATA_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -n "$1" ]; then
  cp "$DATA_DIR/$1.json" "$APP_RESOURCES/$1.json"
  echo "Copied: $1.json"
else
  for f in "$DATA_DIR"/*.json; do
    name="$(basename "$f")"
    cp "$f" "$APP_RESOURCES/$name"
    echo "Copied: $name"
  done
fi
