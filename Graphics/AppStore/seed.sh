#!/bin/bash
# Seed sample notes and launch the app on a booted simulator (no screenshot).
# Usage: seed.sh <device-name> <light|dark>
set -e
cd "/Users/nathan/Documents/GitHub/Alphabetical-List-App"
DEVICE="$1"
APPEARANCE="${2:-light}"
BUNDLE="com.nathanfennel.A2Z"
APP="build/DDR/Build/Products/Release-iphonesimulator/Alphabetical List Utility.app"

xcrun simctl ui "$DEVICE" appearance "$APPEARANCE" 2>/dev/null || true
xcrun simctl terminate "$DEVICE" "$BUNDLE" 2>/dev/null || true
xcrun simctl uninstall "$DEVICE" "$BUNDLE" 2>/dev/null || true
sleep 2
xcrun simctl install "$DEVICE" "$APP"
sleep 2

CONTAINER=$(xcrun simctl get_app_container "$DEVICE" "$BUNDLE" data)

python3 - "$CONTAINER/Library/Preferences/$BUNDLE.plist" <<'PYEOF'
import os, plistlib, sys

plist_path = sys.argv[1]
os.makedirs(os.path.dirname(plist_path), exist_ok=True)

notes = {
    "Camping Trip": "Tent + footprint\nSleeping bags (2)\nCamp stove & fuel\nHeadlamps\nFirst aid kit\nCoffee press\nFirewood\nMarshmallows",
    "Gift Ideas": "Mum — pottery class\nDad — cast iron pan\nSam — headphones\nJo — cookbook\nTeacher — bookshop voucher",
    "Groceries": "Oat milk\nSourdough\nEggs\nSpinach\nCherry tomatoes\nParmesan\nOlive oil\nDark chocolate",
    "Home Improvement": "Patch hallway drywall\nRepaint the trim\nReplace porch light\nSeal the deck\nSwap furnace filter\nHang shelves in office",
    "Reading List": "Piranesi\nThe Overstory\nProject Hail Mary\nA Gentleman in Moscow\nThe Left Hand of Darkness\nKlara and the Sun",
    "Weekend Projects": "Build a raised garden bed\nOrganise the garage\nFix the gate latch\nSet up the darkroom\nRestring the guitar",
    "Workout Plan": "Mon — push (bench, dips)\nTue — 5k easy\nWed — pull (rows, chins)\nThu — mobility\nFri — legs\nSat — long ride\nSun — rest",
}

data = dict(notes)
data["M@$teR I1$7 K3yY"] = "%&&^AB)*971".join(notes.keys())
# "<title>useWebIcon" is inverted: true = web icon OFF. Keep third-party favicons
# out of App Store screenshots; the on-device monogram shows instead.
for title in notes:
    data[f"{title}useWebIcon"] = True

with open(plist_path, "wb") as handle:
    plistlib.dump(data, handle)
print(f"seeded {len(notes)} notes -> {plist_path}")
PYEOF

xcrun simctl launch "$DEVICE" "$BUNDLE" >/dev/null 2>&1 || true
sleep 6
echo ready
