# Contributing to Wristbeam

English and Chinese are welcome. 欢迎用中文或英文参与。You can help without
writing code: try a device session, describe a reading problem, reduce a failing
webpage, improve setup instructions, or review a translation.

## Find a small starting point

- Use a [device report](https://github.com/shenxingy/wristbeam/issues/new/choose)
  for observations, including failures and checks you could not run.
- Report bugs with a public reproduction and expected versus actual behavior.
- Discuss a new receiver, platform, permission, or protocol in
  [Discussions](https://github.com/shenxingy/wristbeam/discussions) before a large PR.
- Check the [roadmap](ROADMAP.md) and existing issues. A short comment can avoid
  duplicate work; small documentation fixes do not need prior permission.

## Develop and verify

Setup instructions are in [README.md](README.md#build-on-a-mac).

For a code change:

1. Run `npm ci` and `npm test` with Playwright Chromium installed (or set
   `CHROME_PATH`).
2. On macOS, run `bash scripts/check-apple.sh` to test the shared Swift core and
   compile the iOS and watchOS targets.
3. Follow the relevant device checks in [docs/validation.md](docs/validation.md).
4. Include each result and each unavailable lane in the PR. Lack of a Mac does
   not prevent a contribution; mark the Apple lane unrun and request platform
   review. A source change or simulator build does not establish device behavior.

For documentation-only changes, check links, instructions, and support claims.
Do not fabricate results or weaken checks. Keep PRs focused on one independently
useful change and describe the observable effect. Use public APIs, never queue
stale gestures across reconnects, and keep both app languages in sync.
Future receivers need pairing, revocation, permissions, and explicit targets
in their initial design. Native accessibility is part of the interaction.

Do not commit `Config/Local.xcconfig`, signing identities, certificates, device
identifiers, personal browsing history, or generated Xcode projects. Change
`project.yml` and regenerate instead. `package-lock.json` is committed.

Website reports should use a public test page or a minimal fixture without
private account data. Include the expected and actual scrolling area. Tests
should observe the page position after input, not merely assert that a command
was sent.

Use short conventional commit subjects (`feat:`, `fix:`, `docs:`, `test:`).
Contributions are licensed under the project's [MIT license](LICENSE). No CLA
or separate copyright assignment is currently required. Follow the
[Code of Conduct](CODE_OF_CONDUCT.md) and [governance](GOVERNANCE.md).
Security vulnerabilities use [SECURITY.md](SECURITY.md), not a public issue.
This small project has no guaranteed response schedule.
