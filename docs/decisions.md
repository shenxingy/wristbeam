# Decisions

- 2026-09-26: Working name WristScroll; MIT license. Start in a separate local
  repository. No public repository destination has been selected.
- 2026-09-26: Default to an iPhone web reader plus watchOS companion for the
  first prototype. A Safari extension is a later adapter. The reader keeps the
  receiving iPhone app visible and avoids Safari extension polling during the
  first interaction experiment.
- 2026-09-26: Only live, acknowledged commands. Do not queue gestures for later
  delivery after reconnection. Keep prototype status distinct from verified
  physical-device behavior.
- 2026-09-26: Development host has Node and Chrome, but no Swift, Xcode, Apple
  SDKs, or paired devices. Browser tests can run here; native compilation and
  watch-to-phone validation remain required gates.

