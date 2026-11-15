#!/usr/bin/env bash
# Builds and installs (or upgrades) Pulso for the current user
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/build.sh >/dev/null
ID=$(python3 -c "import json; print(json.load(open('package/metadata.json'))['KPlugin']['Id'])")
if kpackagetool6 -t Plasma/Applet -s "$ID" >/dev/null 2>&1; then
    kpackagetool6 -t Plasma/Applet -u package
else
    kpackagetool6 -t Plasma/Applet -i package
fi
echo "Restart Plasma to load changes: systemctl --user restart plasma-plasmashell"
