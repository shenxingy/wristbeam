# Project governance

Wristbeam is maintained by [@shenxingy](https://github.com/shenxingy). Its goal
is to turn a useful watch-to-reader experiment into small, verifiable
cross-device interactions.

## Decisions

Small fixes can go directly to a PR. Protocol, pairing, permissions, new
platforms, and major dependencies need a short public proposal first: use case,
approach, alternatives, risks, and how to observe success. Discussion is open;
the maintainer makes final scope and release decisions and records material
choices in [docs/decisions.md](docs/decisions.md).

Priorities favor useful interactions, reproducible evidence, maintainability,
and clear ownership. Stars and votes are interest signals, not promises.
Do not present planned adapters as supported.

## Review and releases

Contributions normally use focused PRs. The owner-requested initial repository
publication is a bootstrap; subsequent feature work is reviewed on branches.
Record checks for the exact proposed code. Native behavior needs native
evidence; CI cannot establish physical-device usability.

The maintainer owns release publication. Until an alpha has documented device
evidence, the repository distributes source only. Releases identify tested
OS/device combinations, unsupported targets, setup steps, and known limitations.
Pre-1.0 APIs may change, with changes documented before adoption.

## Growing the project

There are no additional maintainers or platform owners implied by this file.
Someone who repeatedly supports an adapter can propose becoming its maintainer.
The owner grants access explicitly and records the scope here.

Keep active work in issues and milestones. Mark inactive work honestly. There
is no response-time SLA, required contributor workload, or automatic assignment.
Participation follows [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md); redistribution
follows the [MIT license](LICENSE).
