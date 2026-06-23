#!/bin/bash

# magnet-ls — Download metadata from a magnet link and display torrent contents
#
# Usage:
#   ./share/bin/magnet-ls.sh <magnet-uri-or-infohash>
#
# Examples:
#   ./share/bin/magnet-ls.sh "magnet:?xt=urn:btih:dafc8c076ca2f3ed376eeae7c76a0d6be2415c45"
#   ./share/bin/magnet-ls.sh dafc8c076ca2f3ed376eeae7c76a0d6be2415c45
#
# Dependencies: aria2c

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <magnet-uri-or-infohash>" >&2
  exit 1
fi

INPUT="$1"
WORKDIR="/tmp/magnet-ls-$$"

cleanup() {
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

mkdir -p "$WORKDIR"

# If input is a raw infohash (40 hex chars), construct a magnet URI
if [[ "$INPUT" =~ ^[[:xdigit:]]{40}$ ]]; then
  MAGNET="magnet:?xt=urn:btih:$INPUT"
else
  MAGNET="$INPUT"
fi

echo "Downloading metadata from magnet link ..."
aria2c \
  -d "$WORKDIR" \
  --bt-save-metadata=true \
  --bt-metadata-only=true \
  --follow-torrent=false \
  --summary-interval=0 \
  --console-log-level=error \
  "$MAGNET" 2>&1

TORRENT_FILE=$(find "$WORKDIR" -name "*.torrent" -print -quit 2>/dev/null || true)

if [ -z "$TORRENT_FILE" ]; then
  echo "Error: failed to download metadata — no .torrent file created." >&2
  exit 1
fi

echo ""
aria2c -S "$TORRENT_FILE"