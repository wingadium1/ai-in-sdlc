# Project Type Guide: CLI / Developer Tool

Developer tools are unique because they serve two distinct user groups: the end-users operating the tool in a terminal and the developers who integrate the tool into their own automation, CI/CD pipelines, or codebases. In this SDLC model, every change to a public API, CLI flag, or configuration schema is a contractual commitment. Breaking changes don't just cause annoyance, they halt downstream production builds. 

Semver is the hard contract governing these relationships. Every release must be classified with precision. The changelog isn't just a summary, it's a first-class artifact used by developers to audit impact before upgrading.

### Core Stacks
* **Node.js**: commander, yargs, oclif
* **Python**: click, typer
* **Rust**: clap
* **Go**: cobra

### Phase-Specific SDLC Differences

| Phase | CLI / Developer Tool focus |
| :--- | :--- |
| **Intake** | Features and bugs originate from GitHub issues, package manager telemetry (npm/PyPI), and community forums. Source tickets must explicitly state current behavior, expected behavior, and the affected API surface (exported functions, classes, or CLI flags). |
| **Define** | Acceptance criteria must classify the change: is this a breaking change (Semver Major)? If breaking, a migration path must be defined. Every change must include a preview of the new `--help` output. |
| **Decide** | The primary decision is breaking vs non-breaking. Check all public exports, flags, and config formats. Deprecations require a sunset timeline. New flags must be additive. Prefer backward-compatible implementations first, deferring cleanups to the next major version. |
| **Produce** | Updates must include type definitions (e.g., `index.d.ts`), `--help` text, man pages, and a `CHANGELOG.md` entry under the `[Unreleased]` section. Deprecation warnings must be implemented in code before removal occurs. |
| **Verify** | Run public API contract tests (snapshots of exports/flags). Perform integration tests in a clean project environment that installs the tool from a local path. Confirm a valid CHANGELOG entry and determine the correct semver bump. |
| **Approve** | Human gates are mandatory for all breaking changes. Non-breaking changes (Minor/Patch) can be auto-passed if all automated verifications succeed. |
| **Integrate** | Bump version per semver. Move `[Unreleased]` content in the CHANGELOG to a versioned header. The publish step to npm/PyPI should be documented but remains a manual or separate CI step for safety. |

### Semver Contract
The ai-in-sdlc framework tracks semver decisions within `.sdlc/decisions/`. Every work item must justify its version impact.
* **Major**: Breaking change to public API, CLI flags, or config schema.
* **Minor**: New backward-compatible feature or flag.
* **Patch**: Backward-compatible bug fix or documentation update.

### Public API Surface Artifact
Store the definitive shape of the tool's public interface in `.sdlc/artifacts/design-artifact/`. This allows agents and humans to compare the current implementation against the intended contract.

### Canonical Examples

#### Command Definition (Commander.js)
```typescript
program
  .command('deploy')
  .description('Deploy the project to the target environment')
  .option('-e, --env <name>', 'target environment', 'production')
  .action((options) => {
    // Implementation
  });
```

#### Exported Library Function
```typescript
/**
 * Deploys the current workspace.
 * @param env - The environment name.
 * @returns A promise that resolves when deployment finishes.
 */
export async function deploy(env: string = 'production'): Promise<void> {
  // Logic
}
```

#### Integration Test (Vitest)
```typescript
import { execSync } from 'child_process';

test('cli returns version', () => {
  const output = execSync('node ./dist/index.js --version').toString();
  expect(output).toMatch(/\d+\.\d+\.\d+/);
});
```

#### CHANGELOG Format
```markdown
## [Unreleased]
### Added
- `--force` flag to the `cleanup` command.
### Fixed
- Memory leak when processing large log files.
```

### Common Conventions
1. Always prioritize backward compatibility.
2. Provide deprecation warnings for at least one minor version before removal.
3. Use kebab-case for CLI flags (e.g., `--output-format`).
4. Help text must be present and descriptive for every command and flag.
5. Exit with non-zero codes on failure and print errors to stderr.
6. Never introduce breaking changes in a patch version.
7. Support both `.rc` and `.json` config file formats during migration.
8. Document all possible exit codes.
9. Ensure the library can be imported without immediate side effects.
10. Treat documentation as part of the public API.

### Team Checklist
- [ ] Is this a breaking change?
- [ ] Is the CHANGELOG updated under `[Unreleased]`?
- [ ] Does the `--help` text reflect all changes?
- [ ] Are integration tests running against the actual binary?
- [ ] Are type definitions updated and exported correctly?
