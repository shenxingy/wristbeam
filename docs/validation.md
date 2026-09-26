# Validation

This document separates source review, browser observations, native builds,
and physical-device behavior. Do not collapse them into a single “works” badge.

## Current evidence

Development host: Linux, Node 22, Google Chrome 154. No Xcode, Swift toolchain,
Apple SDKs, or paired Apple devices are available on this host.

| Lane | Status |
| --- | --- |
| Chromium browser tests | 7 passed: scroll directions, paging/bounds, empty pages, invalid commands, focused/touched nested panels, detached fallback, CSS smooth-scroll override, and bundled sample integration |
| Sample article rendering | No horizontal overflow at 390/768/1280/1440 widths in light and dark mode; sample screenshots reviewed, not native app screenshots |
| Native Swift protocol tests | Written, not run; no Swift toolchain |
| iOS and watchOS builds | Not run; `bash scripts/check-apple.sh` exits 2 and names the missing macOS/Xcode environment |
| Hosted CI | Configured, not run; no remote repository exists |
| WebKit isolated-world integration | Not tested |
| Physical Watch → iPhone | Not tested |
| Native layout / VoiceOver / Dynamic Type | Not tested |
| Battery / latency / wrist-down usability | Not measured |

Command: `CHROME_PATH=/usr/bin/google-chrome npm test`.

The browser engine was mutation-tested: disabling movement caused 5 of the 6
engine tests to fail. The original source was restored and the full suite rerun.
The native code still requires compiler review; it is not an installable
verified release.

## Mac gates

Run `bash scripts/check-apple.sh`. Record the Xcode version, Swift version,
both target build results, and core test results. Do not omit the watch target.
Then sign and install on a paired iPhone and watch using README instructions.

## Device session

Run these from the home screens with Xcode's debugger detached. Record phone
and watch models, OS versions, and whether the watch has Always On enabled.

- [ ] Fresh install opens the sample, with a useful watch setup prompt.
- [ ] Connect → next screen → previous screen visibly changes the phone page.
- [ ] Slow and fast Crown rotation moves in the expected direction without a
      long backlog; a direction reversal responds promptly.
- [ ] At document edges the page stays still and the watch reports the boundary.
- [ ] A focused/touched nested panel scrolls; removing it returns to the document.
- [ ] Switching pages during a gesture never scrolls the replacement page from
      an old command. Back, reload, and target=_blank navigation recover.
- [ ] Background or lock the phone: the watch explains the unavailable reader.
- [ ] Disconnect and reconnect: no stale movement plays back.
- [ ] Wrist-down pauses of 15, 60, and 180 seconds: record exact gestures needed
      to resume and whether the Crown wakes/controls the app as expected.
- [ ] Read for 20 minutes: record dropped commands, perceptible delay, reconnects,
      and battery change. These are observations, not calibrated benchmarks.
- [ ] Keep-awake affects only the foreground phone reader, and stops on app exit.
- [ ] HTTPS load failure, unsupported scheme, WebKit crash/reload, and offline
      sample all have recovery paths.
- [ ] Small iPhone / smallest supported watch, landscape phone, both languages,
      dark mode, large text, Reduce Motion, VoiceOver, and increase-contrast.

## Result template

```text
Commit:
Xcode:
Phone model / OS:
Watch model / OS / Always On:
Debugger detached:
Website or sample:
Passed checks:
Failed checks and reproduction:
Unrun checks:
Resume after 15 / 60 / 180 seconds:
Observed latency / dropouts / battery (or not measured):
```
