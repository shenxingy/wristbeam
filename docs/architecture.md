# Architecture

## One reader, two apps

```mermaid
flowchart LR
    Crown[Watch Crown or buttons] --> Remote[WatchRemote]
    Remote -->|live command with ID and document token| WC[WatchConnectivity]
    WC --> Gate[PhoneSession validation]
    Gate --> Reader[Foreground ReaderModel]
    Reader -->|structured arguments, isolated world| JS[scroll-controller.js]
    JS --> Page[Current WebKit page scroll position]
    Page -->|result after movement| Reply[Reply with progress]
    Reply --> Remote
```

The iPhone reader stays in the foreground. The watch sends small Codable
messages using `sendMessageData`; no background user-info queue is used. The
phone validates size, version, timestamp, numeric range, duplicate IDs, and
document identity before allowing a gesture. It also requires the reader to
be active with a loaded document.

`ReaderModel` injects the bundled engine into `WKContentWorld.defaultClient`
for the main frame only. Calls use named arguments, not string interpolation.
No web-to-native message handler is exposed. No URLs arrive from the watch.

The scroll engine chooses a focused nested scroller, then a remembered touched
scroller, then the document. It reports the actual position after an instant
scroll. WebKit integration has not yet been exercised; Chromium tests establish
only the DOM behavior.

## Command lifecycle

- At most one watch request is in flight; Crown deltas coalesce for 60 ms.
- Replies must match the current request UUID. Late replies are ignored.
- The watch abandons a request after 1.5 seconds, clears pending movement, and
  marks the connection unavailable. It does not retry gestures.
- The phone rejects commands more than 3 seconds in either direction from its
  clock. Paired device clocks need to be synchronized. Expiry is bounded, not
  remote cancellation: an already delivered command may execute before expiry
  even if its reply was lost.
- Navigation gives the reader a new document UUID. Old-page commands fail.
- A foreground watch heartbeat checks readiness every 2 seconds. Scene exit
  clears readiness and pending input; reconnects only ask for current state.
- No workout, audio, or extended runtime session is created. The OS may suspend
  the watch app. Wrist-down use is a required experiment, not a shipped promise.

## Boundaries and later adapters

This avoids system-wide touch injection. A Safari extension could share the
command model but needs a different iPhone delivery adapter: Apple's iOS
containing app cannot directly push messages to extension JavaScript. A pull
mechanism and its timing would need separate tests. Arbitrary native app
control is not part of this architecture.

The following is a **proposed direction, not implemented code**:

```mermaid
flowchart LR
    Input[Watch or future controller] --> Transport[Authenticated transport]
    Transport --> Router[Explicitly paired target and capabilities]
    Router --> Reader[Own reader]
    Router --> Browser[Desktop receiver and browser extension]
    Router --> Media[Player adapter]
```

An input produces an action; a transport delivers it; a receiver checks
ownership, freshness, target, and capability; an adapter performs it and reports
the observed effect. Do not freeze a cross-platform protocol before a second
receiver proves the need. The current scroll/page/ping protocol is specific to
this prototype and has no desktop pairing mechanism.

WatchConnectivity connects the watch and its paired iOS companion, not a Mac,
Windows, or Linux machine. A first desktop experiment can use a phone relay
and an explicitly paired local receiver. Foreground, sleep, authentication,
discovery, and latency behavior must be tested before selecting the transport.
An always-running phone relay is not promised.

Desktop Chrome can investigate native messaging between an extension and a
registered host. Website scripts must never become a privileged command channel.
Safari desktop, Safari iOS, and native OS input need separate permission and
lifecycle analysis. A media adapter should start with its own player or a
documented API. See [ROADMAP.md](../ROADMAP.md) for acceptance criteria.

Sources used for the design:

- [WatchConnectivity](https://developer.apple.com/documentation/watchconnectivity/wcsession)
- [Real-device lifecycle differences](https://developer.apple.com/documentation/watchconnectivity/transferring-data-with-watch-connectivity)
- [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)
- [Safari extension communication](https://developer.apple.com/documentation/safariservices/messaging-between-the-app-and-javascript-in-a-safari-web-extension)
- [Desktop Chrome native messaging](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging)
