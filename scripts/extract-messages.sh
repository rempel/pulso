#!/usr/bin/env bash
# Maintainers: refresh po/pulso.pot and merge it into every translation (needs gettext)
set -euo pipefail
cd "$(dirname "$0")/.."
find package -name '*.qml' -o -name '*.js' | sort | xargs xgettext --from-code=UTF-8 -C --kde \
    -ci18n -ki18n:1 -ki18nc:1c,2 -ki18np:1,2 -ki18ncp:1c,2,3 \
    --package-name=pulso -o po/pulso.pot
for po in po/*.po; do msgmerge -q --update --backup=none "$po" po/pulso.pot; done
