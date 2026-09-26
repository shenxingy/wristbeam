# Wristbeam

Small gestures. More reach.

[简体中文](README.zh-CN.md) · [Roadmap](ROADMAP.md) · [Contribute](CONTRIBUTING.md) · [Discussions](https://github.com/shenxingy/wristbeam/discussions)

Wristbeam is an open-source project for controlling your devices from your
wrist, one useful interaction at a time. The name combines **wrist + beam**:
a small action reaching the screen you are using.

We start with a phone on a stand: an iPhone web reader and an Apple Watch
remote. Turn the Digital Crown for small scrolls, or tap an arrow to move a
screen at a time. The current prototype uses no additional hardware, server,
or account. Desktop browsers, more operating systems, and media players are
future adapters, not features available today.

**Status: source prototype, not a verified native release.** The browser scroll
engine has been tested in Chromium. The iOS/watchOS apps have **not yet been
compiled or tested on physical devices**. The development host is Linux; the
Apple build and device gates below remain open. There are no prebuilt binaries
or TestFlight release. Follow the live [build checks](https://github.com/shenxingy/wristbeam/actions/workflows/check.yml)
and the separate [device evidence](docs/validation.md).

## Grow one working path at a time

| Target | State | Next evidence needed |
| --- | --- | --- |
| Own iPhone reader + Apple Watch | Source prototype; Chromium engine tests pass | Native builds, paired-device use, wrist-down recovery |
| Desktop Chrome; macOS first | Planned | One explicitly paired computer and selected tab |
| Windows / Linux receivers | Planned | Per-OS installation and compatibility evidence |
| Safari on macOS / iOS | Separate research tracks | Platform-specific messaging and lifecycle experiments |
| Own player, then other media apps | Planned | One documented playback API and observable action |
| Other watches / input devices | Open direction | A contributor-owned, tested adapter |

The [roadmap](ROADMAP.md) defines small milestones and completion criteria.
We use public APIs available today; future platform changes can unlock new
adapters without being a prerequisite for the project.

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
open Wristbeam.xcodeproj
```

1. Select the `Wristbeam` scheme and your physical iPhone. Build and run.
2. Select `WristbeamWatch` and its paired Apple Watch. Build and run.
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
browser and Apple lanes. Hosted results are available in the build-check link
above; a green simulator build still does not establish physical-device behavior.

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

Useful first contributions are native build fixes, device test results,
reproducible website compatibility reports, and clearer setup instructions.
English and Chinese are welcome. You do not need to write Swift to contribute.

- [Report a bug or device test](https://github.com/shenxingy/wristbeam/issues/new/choose).
- [Discuss a use case or adapter](https://github.com/shenxingy/wristbeam/discussions).
- Read [CONTRIBUTING.md](CONTRIBUTING.md), [community plans](docs/community.md),
  and [project governance](GOVERNANCE.md).
- Report vulnerabilities through [SECURITY.md](SECURITY.md).

MIT licensed. Apple Watch and iPhone are trademarks of Apple Inc. This project
is independent of Apple.
