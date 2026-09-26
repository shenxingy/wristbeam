# WristScroll

Read on your iPhone. Scroll from your Apple Watch.

[简体中文](README.zh-CN.md) · [Device validation](docs/validation.md) · [Architecture](docs/architecture.md)

WristScroll is an MIT-licensed experiment for reading with a phone on a stand.
It pairs an iPhone web reader with an Apple Watch remote: turn the Digital Crown
for small scrolls, or tap an arrow to move one screen at a time. No additional
hardware, server, or account is used by the app.

**Status: source prototype, not a verified native release.** The browser scroll
engine has been tested in Chromium. The iOS/watchOS apps have **not yet been
compiled or tested on physical devices**. The development host is Linux; the
Apple build and device gates below remain open. There are no prebuilt binaries
or TestFlight release.

## First scope

- Read HTTPS pages inside the included iPhone reader; an offline sample opens
  on first launch.
- Turn the Crown to scroll, or page up/down with 15% overlap.
- See connection, loading, timeout, and page-edge feedback on the watch.
- Optionally keep the iPhone display awake while the reader is visible.
- English and Simplified Chinese controls; system appearance and type styles.

This version controls **its own reader**. It does not scroll Safari, WeChat,
Kindle, or other apps. A Safari extension is a possible later adapter.
Automatic scrolling, custom hand-gesture recognition, and continuous wrist-down
operation are not implemented or promised. Nested panels work after you focus
or touch them on the phone. Cross-origin frames, shadow-root scrollers,
custom canvas viewers, and complex scroll snapping are outside the prototype's
tested scope.

## Build on a Mac

Requirements: full Xcode 16 or newer with iOS/watchOS SDKs, XcodeGen 2.44 or
newer, and a paired iPhone (iOS 17+) and Apple Watch (watchOS 10+) for live tests.
The exact Xcode/device combination is not yet validated.

```bash
brew install xcodegen
cp Config/Local.xcconfig.example Config/Local.xcconfig
```

Edit `Config/Local.xcconfig` with your signing team and a unique reverse-domain
prefix. Both app IDs and the watch's companion ID derive from that one prefix.
Keep this local file out of Git. Select your Apple account in Xcode and follow
its signing and Developer Mode prompts for both devices.

```bash
xcodegen generate
open WristScroll.xcodeproj
```

1. Select the `WristScroll` scheme and your physical iPhone. Build and run.
2. Select `WristScrollWatch` and its paired Apple Watch. Build and run.
3. Keep the reader visible on iPhone; open the remote on the watch. Wait for
   “Ready to scroll”, then try the sample article with the arrows and Crown.
4. Relaunch both apps directly from their home screens, disconnected from the
   debugger, for the real lifecycle tests in [validation.md](docs/validation.md).

The watch's system pairing carries messages. Do not look for a new Bluetooth
mouse or enable Accessibility permission for this app. No background workout
or audio session is used to keep the watch alive.

## Checks

```bash
# Browser behavior, on Linux or macOS:
npm ci
npx playwright install chromium
npm test

# Alternatively, use an existing Chrome executable:
CHROME_PATH=/path/to/google-chrome npm test

# On macOS with Xcode and XcodeGen:
bash scripts/check-apple.sh
```

The Apple script runs `swift test` for the command/URL boundaries and unsigned
simulator builds of **both** native targets. It exits with an error on Linux;
an unavailable build is not a passing build. GitHub Actions defines the same
browser and Apple lanes, but no hosted run has occurred yet.

Browser tests observe actual scroll positions, including nested scrolling,
limits, invalid input, and pages with CSS smooth scrolling. They do not test
WebKit, the isolated JavaScript world, WatchConnectivity, signing, native
layout, battery use, or wrist-down behavior.

## Browsing and connection behavior

The reader uses a temporary WebKit data store. Cookies and logins are not kept
between app sessions; it is not a replacement for your everyday browser.
Websites still make their own network requests. The app adds no analytics or
relay server. Watch messages contain command IDs, timestamps, gestures, and
reading progress, not page text or browsing URLs.

Gestures are live messages, never a background transfer queue. Failed or
timed-out gestures are not retried. Commands expire after three seconds, are
deduplicated, and bind to the current document so a delayed gesture cannot
scroll a newly loaded page. Crown input is coalesced with at most one request
in flight. See [architecture.md](docs/architecture.md) for the remaining limits.

## Contribute

Useful first contributions are a clean Xcode build, device test results, and
reproducible website compatibility reports. Include device/OS versions and
whether a debugger was attached. See [CONTRIBUTING.md](CONTRIBUTING.md).

MIT licensed. Apple Watch and iPhone are trademarks of Apple Inc. This project
is independent of Apple.
