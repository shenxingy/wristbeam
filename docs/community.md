# Building the Wristbeam community

Start with people trying a real interaction: reading with a phone on a stand,
controlling a browser across the room, or using their own player. Grow from
their observations rather than an unsupported compatibility list.

## Places to participate

| Place | Use it for |
| --- | --- |
| [Issues](https://github.com/shenxingy/wristbeam/issues) | Reproducible bugs, device evidence, small accepted tasks |
| [Discussions](https://github.com/shenxingy/wristbeam/discussions) | Use cases, questions, adapter ideas, design proposals |
| [Pull requests](https://github.com/shenxingy/wristbeam/pulls) | One reviewable change and its checks |
| [Milestones](https://github.com/shenxingy/wristbeam/milestones) | Reader alpha and first desktop experiment |
| [Private reports](https://github.com/shenxingy/wristbeam/security/advisories/new) | Security vulnerabilities |

Start on GitHub. No chat server, newsletter, mandatory in-app account, or second
task tracker is needed. English and Chinese are welcome; an English summary of
technical decisions helps wider review.

## Initial rhythm

1. **Invite evidence:** successful and failed device sessions both help. Give
   testers a concrete script and share observations with consent.
2. **Choose a small problem:** fix reading blockers before expanding platforms.
   Keep only a few tasks actively assigned.
3. **Show a working interaction:** after verification, share a short recording
   and exact setup. A mockup is not a device demo.
4. **Open one adapter experiment:** state transport, permissions, target, and
   a pass/fail observation. Require evidence before claiming support.
5. **Credit contributions:** recognize code, testing, translation, and issue
   reduction in release notes using contributors' preferred names.

There is no calendar promise. The maintainer triages when available and explains
priority changes in milestone descriptions.

## Labels and entry points

- `bug`, `enhancement`, `documentation`: the kind of change or report.
- `device-report`: actual hardware observations, including failures.
- `research`: a feasibility or design experiment.
- `area:reader`, `area:watch`, `area:desktop`, `area:browser`, `area:media`:
  the affected component or proposed target.
- `help wanted`: outside evidence or expertise would help.
- `good first issue`: only for bounded tasks with a clear result and a verifier
  that does not require unspecified hardware or architecture work.

An entire platform port is not a good first issue. Do not auto-close a valid
bug just for its age. Link duplicates; explain unsupported requests without
dismissing the person's use case.

## What progress means

Look for people completing the task, reproducible setup, repaired bugs,
maintained device/OS evidence, and a second contributor able to run the checks.
Stars alone do not establish quality. Do not invent adoption numbers, user
testimonials, or performance measurements.

## 中文参与说明

可以先说清楚“用什么设备、想控制哪个目标、完成什么动作”。反馈不必带代码，
失败的真机测试同样有价值。Issue 记录具体问题，Discussion 讨论方向。
我们先完善手边能验证的交互，再加入电脑、浏览器和播放器；不会把计划写成
已经支持，也不会要求新贡献者独自完成一个庞大的平台移植。
