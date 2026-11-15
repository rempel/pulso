#!/usr/bin/env bash
# Compiles translations and packs dist/pulso-<version>.plasmoid
set -euo pipefail
cd "$(dirname "$0")/.."

meta() { python3 -c "import json; print(json.load(open('package/metadata.json'))['KPlugin']['$1'])"; }
ID=$(meta Id)
VERSION=$(meta Version)

rm -rf package/contents/locale
for po in po/*.po; do
    lang=$(basename "$po" .po)
    dir="package/contents/locale/$lang/LC_MESSAGES"
    mkdir -p "$dir"
    python3 scripts/msgfmt.py "$po" "$dir/plasma_applet_$ID.mo"
done

mkdir -p dist
out="dist/pulso-$VERSION.plasmoid"
rm -f "$out"
(cd package && zip -qr "../$out" metadata.json contents)
echo "$out"
