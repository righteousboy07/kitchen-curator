#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 -m pip install -e '.[desktop]'
python3 -m PyInstaller --noconfirm --clean --windowed --name 'Kitchen Curator' --osx-bundle-identifier 'com.kitchencurator.app' --collect-all webview --paths src src/kitchen_curator/app.py
mkdir -p release
hdiutil create -volname 'Kitchen Curator' -srcfolder 'dist/Kitchen Curator.app' -ov -format UDZO "release/Kitchen-Curator-$(uname -m).dmg"
