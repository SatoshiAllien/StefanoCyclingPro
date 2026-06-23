#!/bin/bash
# StefanoCyclingPro 2.0 — setup da terminale (macOS)
set -euo pipefail

REPO="https://github.com/SatoshiAllien/StefanoCyclingPro.git"
DIR="${HOME}/StefanoCyclingPro"
XCCONFIG="${DIR}/Config/Development.xcconfig"

echo "=== StefanoCyclingPro 2.0 Setup ==="

if [ -d "$DIR/.git" ]; then
    echo "→ Aggiornamento repo esistente in ${DIR}"
    cd "$DIR"
    git checkout -- StefanoCyclingPro.xcodeproj/project.pbxproj 2>/dev/null || true
    git pull origin main
else
    echo "→ Clone in ${DIR}"
    git clone "$REPO" "$DIR"
    cd "$DIR"
fi

if grep -q "TEAMID_PLACEHOLDER" "$XCCONFIG" 2>/dev/null; then
    echo ""
    echo "⚠️  Imposta il Team ID in:"
    echo "   ${XCCONFIG}"
    echo "   DEVELOPMENT_TEAM = IL_TUO_TEAM_ID"
    echo ""
fi

rm -rf "${HOME}/Library/Developer/Xcode/DerivedData/StefanoCyclingPro-"* 2>/dev/null || true

echo "→ Apertura Xcode..."
open "${DIR}/StefanoCyclingPro.xcodeproj"

echo ""
echo "✅ Pronto. In Xcode: ⇧⌘K Clean → ⌘B Build → ⌘R Run su iPhone"
echo "   Repo: ${REPO}"