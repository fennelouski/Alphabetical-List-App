#!/bin/bash
set -eu
cd "$(dirname "$0")/../.."
test_dir=$(mktemp -d /tmp/atoz-place-checks.XXXXXX)
trap 'rm -rf "$test_dir"' EXIT
# Live service integration. No CLLocationManager or sensor permission is used.
xcrun swiftc "Alphabetical List Utility/ALUNoteDetails.swift" "Alphabetical List Utility/ALUPlaceDiscovery.swift" Tests/PlaceDiscoveryChecks/main.swift -o "$test_dir/checks"
"$test_dir/checks"
