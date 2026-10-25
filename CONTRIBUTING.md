# Contributing to Kids Mode

Thank you for your interest in contributing to Kids Mode, a PIN-locked kids' screen for Android TV! Contributions are welcome, and this page
keeps the process clear and simple.

## Ways to Contribute

- Report bugs or request features using [GitHub Issues](../../issues).
- Improve documentation (README, code comments, the docs folder).
- Submit Pull Requests (PRs) with bug fixes, improvements, or new features.

## Where Things Are

- The kids' screen and the home handover (`KidsHomeActivity`), the guard (`GuardService`), the parents' screen
  (`ParentActivity`), the PIN and its hash (`Lock`), and the rules for which apps start on the kids' screen (`Kids`).
- The module card for the Clean Your TV launcher.

## Code Style

- Plain Java 17 and the Android SDK, no libraries.
- Match the code around you: its naming, comment style and size.
- Comments say why, not what.
- Keep things simple (KISS principle). The APK stays small.

## Pull Request Guidelines

1. **Fork** the repository.
2. Create a new branch for your feature or bugfix:
   ```bash
   git checkout -b feature/my-new-feature
   ```
3. Commit changes with clear, descriptive messages.
4. Make sure it builds and the tests pass: `./gradlew assembleRelease testReleaseUnitTest lintRelease`.
5. Open a Pull Request and describe your changes.

## Tests

- The JVM tests run with `./gradlew testReleaseUnitTest`. Add tests for logic that doesn't need a TV.
- Test on a real TV when you can: a new PIN, Start Kids Mode, an allowed app, the guard sending Settings, another app and Home back, Grown-ups, and a cold reboot with Kids Mode off. Say what you tested in the PR, and what you couldn't.
- Screenshots in issues and PRs: hide IP addresses, network names, device names and accounts.

## Community

We value respectful collaboration. By contributing, you agree to follow our [Code of Conduct](CODE_OF_CONDUCT.md).

Thank you for helping make this project welcoming!
