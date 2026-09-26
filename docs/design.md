# Design Decisions

- **Scope lane:** Full evidence scope because this is a new cross-device
  interaction. Native rendering and outcome checks remain unavailable, rather
  than being inferred from source.
- **Platform:** iPhone touch and Apple Watch Crown/buttons. The Apple interface
  adapter was used. The app has no web dashboard or public marketing surface.
- **Design Read:** A native reading utility for someone with a phone on a stand,
  optimizing opening a page, moving it from the wrist, and recovering connection.
- **Profile:** `clade.design-direction/v1`, V1, greenfield, `system-native`,
  family SwiftUI, composition 1 / motion 1 / density 3, system appearance,
  no signature animation, no overrides.
- **Style DNA:** Direct, quiet, readable. Standard system type, a single web
  reading surface, native arrows, text connection states. Native button radii;
  no custom cards, shadows, gradients, or decorative motion. Spacing 8/16/24/32.
- **Directions considered:** (1) Native compact controls — selected to preserve
  reading area and platform behavior. (2) Editorial serif reading shell —
  rejected because remote websites already supply typography. (3) Instrument
  panel with telemetry — rejected because it competes with reading and adds
  implementation details to the user flow.

## Benchmark and limits

| Reference | Observed evidence | Applied hypothesis |
| --- | --- | --- |
| [Apple HIG](https://developer.apple.com/design/human-interface-guidelines/) / SwiftUI controls | Native control, appearance, and accessibility contracts | Keep navigation, text input, buttons, and settings native |
| [Auto Scroll Web](https://apps.apple.com/us/app/auto-scroll-web/id6740224842) | Listing describes Watch remote and Safari setup; reports page compatibility limits | A ready/failed state must be visible; no silent assumption of delivery |
| [PagePilot](https://apps.apple.com/cn/app/pagepilot/id6760964443) | Listing targets phone-on-stand reading and Crown turning | Start with one reader whose page we can directly control |
| [Things, Apple Design Awards](https://www.apple.com/newsroom/2017/06/apple-design-awards-celebrate-the-best-in-innovation-and-creativity/) | Awarded native utility across iOS/watchOS | Use task hierarchy rather than a branded dashboard; no copied layout |
| Mature system: SwiftUI / Apple HIG | System form, button, toolbar, Dynamic Type primitives | Reuse their state behaviors and semantics |
| Counterexample: CSS smooth scrolling | Browser regression shows delayed movement after a synchronous response | Explicit instant scrolling for acknowledged gestures |

Competitor evidence is from listings and documentation, **not** observed
physical-device flows. No claim of superiority or complete benchmark usability
testing is made.

## Screens and controls

- iPhone reader: URL field and open action, reading content, secondary paging
  controls, connection text; loading/error states with reload/sample recovery.
- iPhone help: native Form with instructions, one keep-awake toggle, scope text.
- Watch remote: textual readiness first, previous/next buttons, Crown hint,
  optional progress. Connect action replaces controls when unavailable.
- `iOS/ComponentLab.swift`: DEBUG-only native previews of type, input, buttons,
  disabled/loading/error states, toggle, large text and dark appearance. These
  previews are written but have not been rendered on this host.

Controls use system typography, semantic foregrounds, native bordered button
styles, and no custom elevation. Icon-only reading buttons declare 44-point
minimum targets and text accessibility labels. Watch Crown focus stays on the
remote container; its VoiceOver adjustment maps to the same paging action.
Actual focus behavior and smallest-watch layout still need device review.

The sample article uses four type sizes, one system font, restrained line
length, and explicit light/dark color tokens. It has no animations. App scrolling
is an explicit user action; no smooth-scroll timer overrides Reduce Motion.

## Verification and review

- Source lint covers the HTML and JavaScript resources only. The installed
  linter **does not inspect SwiftUI**. Its 0 FAIL / 0 WARN result cannot clear
  native design checks. No initial corrective lint loop was needed.
- HTML lint reports headings and declared contrast. Rendered article checks
  use 390/768/1280/1440 widths in light and dark mode, offline. Captures go in
  ignored `test-results/`. They are actual sample content, not mockups of iOS
  or watchOS UI.
- Native preview/simulator screenshots, VoiceOver, Dynamic Type, increased
  contrast, watch layout, and user-task outcomes: **unverified**. Native P0/P1
  counts and worst native contrast are unmeasured. The native screenshot loop
  is not complete.
- Marketing/brand variants, charts, tables, hover, and signature motion: N/A
  to the current native reading flow.
- Device and outcome work remains in [validation.md](validation.md). The
  project owner or contributor running a Mac/device session must record it
  before calling this a usable native release.
