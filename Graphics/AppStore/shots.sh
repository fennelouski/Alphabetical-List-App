#!/bin/bash
# Capture App Store screenshots with seeded sample notes.
# Usage: shots.sh <device-name> <prefix> <light|dark>
#
# Seeding trick: uninstall first so the app has never run in the new container. cfprefsd
# then has nothing cached for the bundle id, so the preferences file we write before the
# first launch is what the app actually reads.
set -e
cd "/Users/nathan/Documents/GitHub/Alphabetical-List-App"
DEVICE="$1"
PREFIX="$2"
APPEARANCE="${3:-light}"
OUT="/private/tmp/claude-501/-Users-nathan-Documents-GitHub-Alphabetical-List-App/e901546b-6cd5-40f7-a63c-e5ad0256bb8b/scratchpad/appstore"
BUNDLE="com.nathanfennel.A2Z"
APP="build/DDR/Build/Products/Release-iphonesimulator/Alphabetical List Utility.app"

mkdir -p "$OUT"

# Boot and wait for the device to actually be ready.
xcrun simctl boot "$DEVICE" 2>/dev/null || true
for _ in $(seq 1 60); do
  state=$(xcrun simctl list devices 2>/dev/null | grep -F "$DEVICE (" | head -1)
  case "$state" in *Booted*) break;; esac
  sleep 2
done
sleep 5
xcrun simctl ui "$DEVICE" appearance "$APPEARANCE" 2>/dev/null || true

# Fresh container => no cached preferences for this bundle id.
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

with open(plist_path, "wb") as handle:
    plistlib.dump(data, handle)
print(f"seeded {len(notes)} notes -> {plist_path}")
PYEOF

xcrun simctl launch "$DEVICE" "$BUNDLE" >/dev/null 2>&1 || true
sleep 8
xcrun simctl io "$DEVICE" screenshot "$OUT/${PREFIX}.png" 2>&1 | tail -1
sips -g pixelWidth -g pixelHeight "$OUT/${PREFIX}.png" 2>/dev/null | tail -2
