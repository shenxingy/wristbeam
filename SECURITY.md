# Security policy

Wristbeam distributes an experimental source prototype, with no supported
production release or independent security audit. Reports affecting the current
default branch are welcome. There is no guaranteed response time or bug bounty.

## Report privately

Use [GitHub private vulnerability reporting](https://github.com/shenxingy/wristbeam/security/advisories/new).
Include the commit, reproduction, expected boundary, and impact. Use a minimal
fixture and redact credentials, personal URLs, device identifiers, and private
content. Do not post sensitive exploit details in a public issue. If the private
form is unavailable, open an issue requesting a private contact route without
including vulnerability details.

## Boundaries

The current reader uses the paired Watch/iPhone session and a foreground reader.
Commands are bounded, expire, and identify a document; pages receive no native
command handler. These are design boundaries, not audit claims. See
[architecture](docs/architecture.md).

Future network receivers must require explicit pairing, authenticated commands,
revocation, an explicit target, and bounded capabilities. Sharing a network does
not authorize input. Do not expose a remote shell or forward untrusted page
messages to privileged OS operations. Review these boundaries before shipping.
