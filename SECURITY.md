# Security Policy – Kids Mode

Kids Mode locks an Android TV to a kids' screen behind a PIN. It is the TV's home app and runs an accessibility
service, so how it handles the PIN and what the guard can see are taken seriously.

---

## Reporting a Vulnerability

If you discover a security vulnerability, including a way for a child to get past the guard without the PIN:

- Do NOT open a public issue.
- Use GitHub's [Private Vulnerability Reporting](../../security/advisories/new) for this repo.
- Include:
  - A clear description of the issue
  - Steps to reproduce
  - Affected version(s)
  - Any logs or screenshots (sanitized: no IP addresses, network names, device names or accounts)

Please allow reasonable time for investigation and patching before public disclosure.

Responsible disclosure is required.

---

## The PIN

- The PIN or password is never stored: only a salted PBKDF2 hash of it, in the app's private storage (backups are
  off).
- After five wrong tries, each further try waits: 30 seconds, doubling up to 5 minutes.
- Clearing the app's data removes the PIN and switches the guard off; while Kids Mode is on, Settings is guarded.

---

## The Guard

- An accessibility service with `canRetrieveWindowContent="false"`: it learns which app's window is in front, and
  nothing else. It never reads what is on screen and filters no keys.
- It acts only while Kids Mode is on: any app that isn't on the kids' screen is sent back to it.
- It is a guard, not a vault: see Known Limitations in the README.

---

## Network Exposure

- Kids Mode has no internet permission: nothing leaves the TV. No accounts, telemetry, ads or libraries.
- Never forward ADB (port 5555) to the internet.

---

## Supported Versions

Security updates are applied to:

- The latest tagged release

Older versions may not receive patches.

---

## Secure Development Practices

Kids Mode development guidelines:

- Never store or log the PIN, only its salted hash
- No debug backdoors, no remote logging, no analytics
- No internet permission
- The guard reads only which app is in front

Pull Requests touching the PIN, the guard or the home handover will receive additional review.
