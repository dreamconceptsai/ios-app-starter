#!/usr/bin/env bash
# Builds and runs all tests on an iPhone simulator.
# Override the simulator with:  SIMULATOR_NAME="iPhone 16 Pro" ./scripts/test.sh
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -d StarterApp.xcodeproj ]; then
  echo "Generating Xcode project…"
  xcodegen generate
fi

DEVICE="${SIMULATOR_NAME:-$(xcrun simctl list devices available \
  | grep -Eo 'iPhone [^()]+' \
  | sed 's/[[:space:]]*$//' \
  | head -n 1)}"

if [ -z "$DEVICE" ]; then
  echo "No iPhone simulator found. Install one in Xcode › Settings › Components." >&2
  exit 1
fi

echo "Testing on simulator: $DEVICE"

xcodebuild test \
  -project StarterApp.xcodeproj \
  -scheme StarterApp \
  -destination "platform=iOS Simulator,name=$DEVICE" \
  CODE_SIGNING_ALLOWED=NO
