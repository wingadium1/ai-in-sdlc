---
applyTo: "src/**"
name: "SDLC CLI / Developer Tool Rules"
---

# Phase Contract
Every change must advance through the universal SDLC phases (Intake, Define, Decide, Produce, Verify, Approve, Integrate). Each phase must produce the required artifacts in the `.sdlc/` directory.

# Semver Contract
Before making any code change, you must classify its impact:
- **PATCH**: Bug fix with no change to the public API surface.
- **MINOR**: New feature or addition that is backward compatible.
- **MAJOR**: Any change that breaks backward compatibility.

Record this classification in the `PhasePacket` under `risk_flags`. Never introduce breaking changes in a PATCH or MINOR version.

# Public API Surface
Every exported function, class, type definition, CLI command, and flag constitutes a public contract.
- Changing a parameter name, removing a flag, or altering a return type is a breaking change.
- When in doubt, add a new API rather than changing an existing one.

# Deprecation Process
Before removing a public API:
1. Add a deprecation warning in the current version.
2. Document the migration path in the `CHANGELOG.md` under `[Unreleased]`.
3. Set a clear removal target version (the next Major version).
4. Remove the API only in that declared Major version.

# Help Text
Every CLI command and flag must have complete `--help` text. Help text is a part of the public API; changes to its structure can break automated scripts that parse it.

# Error Messages
- Exit with a non-zero status code on any failure.
- Print error messages and warnings to `stderr`, never to `stdout`.
- Error messages must be actionable, providing the user with steps to resolve the issue.

# Configuration
Changes to configuration file formats are breaking changes. Support multiple formats (e.g., both `.toolrc` and `.toolrc.json`) during migration periods to ensure a smooth transition for users.

# Testing
- **Unit Tests**: Use for internal business logic and utilities.
- **Integration Tests**: Must spawn the actual compiled binary process. Never mock the process itself.
- **Coverage**: Test the happy path and all error paths, including invalid input, missing configuration, and environment failures.

# CHANGELOG
Every pull request must update `CHANGELOG.md` under the `[Unreleased]` header.
Use the following format:
```markdown
## [Unreleased]
### Added
- [New feature description]
### Changed
- [Backward compatible change description]
### Deprecated
- [Description of API to be removed]
### Removed
- [Description of removed API]
### Fixed
- [Bug fix description]
### Security
- [Security fix description]
```

# What to Never Do
- No breaking changes without a major version bump.
- No removal of public APIs without a formal deprecation period.
- No commands or flags without help text.
- No `stdout` output when running in library mode.
- No side effects occurring upon module import.

# Artifact Traceability Rule
Every line of code changed must be traceable to a specific phase and work item in the `.sdlc/` directory.
