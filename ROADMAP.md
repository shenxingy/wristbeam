# Wristbeam roadmap

Build one useful path, prove it works, then add another. These are ordered
directions, not release dates or supported-platform claims. English and Chinese
proposals are welcome in [Discussions](https://github.com/shenxingy/wristbeam/discussions).

## Now — v0.1: a reader worth using

**Scenario:** your phone is on a stand; your watch moves the article.

- Compile both Apple targets and run the shared protocol tests.
- Record a complete paired-device session with the debugger detached.
- Validate Crown direction, page overlap, reconnection, and document changes
  without delayed gestures moving the wrong page.
- Record what happens after 15 / 60 / 180 seconds with the wrist lowered.
- Review the smallest supported watch, large text, VoiceOver, and both languages.
- Collect public, minimal fixtures for incompatible scrolling layouts.

**Exit:** native builds pass, at least one reproducible phone/watch session is
documented, and a 20-minute reading session has no unresolved accidental-page
movement or connection failures that prevent completing the session. Report
observed latency/battery and limitations; do not invent performance numbers.
This can justify a labeled alpha, not universal compatibility. The
[device checklist](docs/validation.md) is the evidence record.

## Next — v0.2: one computer, one browser

**Scenario:** your watch scrolls an explicitly selected Chrome tab on your Mac.

- Start with a transport experiment: Apple Watch → paired iPhone → local
  desktop receiver. WatchConnectivity itself is not a desktop transport.
- Compare a foreground phone relay with any supported direct-watch route only
  after lifecycle testing. Document whether the phone must remain visible.
- Design pairing, revocation, target selection, and capability discovery before
  exposing a network receiver. A shared Wi-Fi network is not permission.
- Use a narrow scroll/page command model and an extension/host bridge.
  Do not build a remote shell or silently control every browser tab.
- Test permission denial, disconnect, restart, and stale-command behavior.

**Exit:** one documented Mac/Chrome combination can pair, scroll a selected tab,
disconnect, and revoke access; another client cannot control it without pairing.
Setup instructions state every component and permission needed. This milestone
must not regress the original reader.

## After that — earn each new target

| Direction | First small contribution | Evidence before calling it supported |
| --- | --- | --- |
| Windows | Package the desktop/browser path | Clean installation, pairing/revocation, Chrome on a named Windows version |
| Linux | Package a named distribution | Browser behavior on a named distro/session; no blanket X11/Wayland input claims |
| Safari on macOS | Minimal extension messaging prototype | Selected-tab control and extension lifecycle on a real Mac |
| Safari on iOS | Separate delivery/lifecycle experiment | A watch action moves a Safari page; foreground states and delay recorded |
| Own media player | Play/pause and seek in a controlled player | Actual playback changes, bounded seek, explicit active-player selection |
| Other players | One documented public API adapter | Supported app/version, permissions, authentication, and failure recovery |
| Other watches / controllers | One contributor-maintained input adapter | Real-device evidence and an identified maintainer |

Desktop Chrome is an initial target because its native-messaging mechanism has
documented macOS, Windows, and Linux host setups. This is an implementation
option, not proof of Wristbeam support. See
[Chrome's documentation](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging).

Safari on iOS and macOS have different messaging constraints; they must not
share a single “Safari supported” checkbox. See
[Apple's extension documentation](https://developer.apple.com/documentation/safariservices/messaging-between-the-app-and-javascript-in-a-safari-web-extension).

## Longer horizon

Presentations, reading apps, accessibility-oriented interaction, and personal
devices are welcome proposals. Begin with a concrete person, target, action,
and public API. New vendor capabilities may open new adapters; their arrival
is not assumed or scheduled here.

No current commitment: system-wide iOS touch injection, private APIs,
background-mode workarounds, unauthenticated LAN control, mandatory cloud
accounts, arbitrary shell execution, or controlling devices without consent.

## How a direction becomes work

1. Describe one use case in a Discussion or feature issue.
2. Establish the platform API and a small proof across the device boundary.
3. Agree on permissions, target selection, and a bounded acceptance test.
4. Implement a focused PR; record checks and unavailable lanes.
5. Add device evidence and setup instructions before updating support claims.

Current work lives in [Milestones](https://github.com/shenxingy/wristbeam/milestones).
Ideas may stay unassigned. Popularity informs priority but does not create a
delivery promise or prove platform feasibility.
