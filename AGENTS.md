# WristScroll

This is a new, local, MIT-licensed iOS/watchOS source prototype. Read README.md
and docs/validation.md before claiming functionality. No native build or device
result is implied by the existence of the source or CI configuration.

- iOS/, Watch/, Shared/ contain native code. project.yml is the project source.
- Resources/ holds shared localization. iOS/Resources/ holds the scroll engine
  and offline sample. Keep both app languages in sync.
- Run `npm test` for browser behavior; on a Mac also run
  `bash scripts/check-apple.sh`. Never convert unavailable checks into passes.
- Never queue remote gestures across disconnections or replay old Crown input.
- Keep personal signing settings in ignored Config/Local.xcconfig.
- Stage only task-owned paths and use conventional commit subjects.
- Creating local commits does not authorize public repository creation, push,
  app distribution, or changes to any unrelated repository.
