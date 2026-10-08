#!/bin/bash
set -eu
cd "$(dirname "$0")/../.."
test_dir=$(mktemp -d /tmp/atoz-details-checks.XXXXXX)
trap 'rm -rf "$test_dir"' EXIT
xcrun swiftc "Alphabetical List Utility/ALUNoteDetails.swift" "Alphabetical List Utility/ALUPlaceDiscovery.swift" Tests/NoteDetailsChecks/main.swift -o "$test_dir/checks"
"$test_dir/checks"
