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
- 2026-09-26: Rename the project to Wristbeam (wrist + beam) for a broader
  cross-device direction. Public-web checks and GitHub repository search found
  no obvious same-name software; this was a lightweight naming check.
- 2026-09-26: The owner requested publication as the public personal repository
  shenxingy/wristbeam, including community planning. Keep the initial reader
  source while planning desktop, browser, and media adapters in small stages.
  No claim about future Apple permissions is required for the roadmap.
- 2026-09-26: Bootstrap the new repository's main branch from the reviewed
  source checkpoint. This is the owner-requested initial publication; subsequent
  contributions use focused PRs. Do not publish a binary release before device
  evidence exists. GitHub macOS CI supplements, rather than replaces, the
  unavailable local Apple build lane.
- 2026-09-26: The first public CI run (36279902944, source commit 5d919fb)
  passed 7 browser tests, 3 shared Swift tests, and both simulator target builds
  using Xcode 16.4. Update build claims while keeping physical-device,
  accessibility, latency, and wrist-down evidence explicitly pending.
