# Contributing

Keep changes focused on remote reading. Do not add private iOS APIs,
system-wide input claims, or unrelated watch background modes to this prototype.

For a code change:

1. Run `npm ci` and `npm test` with Playwright Chromium installed (or set
   `CHROME_PATH`).
2. On macOS, run `bash scripts/check-apple.sh` to test the shared Swift core and
   compile the iOS and watchOS targets.
3. Follow the relevant device checks in [docs/validation.md](docs/validation.md).
4. Include each result and each unavailable lane in the PR. A source change
   or simulator build does not establish physical-device behavior.

Do not commit `Config/Local.xcconfig`, signing identities, certificates, device
identifiers, personal browsing history, or generated Xcode projects. Change
`project.yml` and regenerate instead. `package-lock.json` is committed.

Website reports should use a public test page or a minimal fixture without
private account data. Include the expected and actual scrolling area. Tests
should observe the page position after input, not merely assert that a command
was sent.

Use short conventional commit subjects (`feat:`, `fix:`, `docs:`, `test:`).
Contributions are licensed under the project's MIT license.
