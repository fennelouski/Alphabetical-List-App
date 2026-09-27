#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
check_dir=$(mktemp -d /tmp/atoz-service-checks.XXXXXX)
trap 'rm -rf "$check_dir"' EXIT
xcrun clang -fobjc-arc -fblocks -framework Foundation -I 'Alphabetical List Utility' Tests/ServicePrivacyChecks/main.m -o "$check_dir/check-services"
"$check_dir/check-services"
