#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ "$(uname -s)" != Darwin ]]; then
  echo "Apple build unavailable: macOS with Xcode is required." >&2
  exit 2
fi
command -v xcodegen >/dev/null
command -v xcodebuild >/dev/null
command -v swift >/dev/null
xcodegen generate
swift test
xcodebuild -project Wristbeam.xcodeproj -scheme Wristbeam \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Wristbeam.xcodeproj -scheme WristbeamWatch \
  -configuration Debug -destination 'generic/platform=watchOS Simulator' \
  -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
