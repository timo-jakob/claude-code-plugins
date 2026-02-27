# Claude Code Plugins

A collection of plugins for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Plugins

### development

Language-agnostic workflow tooling for git operations, committing, and branch management.

**Skills:**

| Skill | Command | Description |
|-------|---------|-------------|
| Commit | `/development:commit [message]` | Runs formatting/linting (delegates to language-specific plugin), generates a commit message, ensures a feature branch, and commits |
| Git Branch Naming | `/development:git-branch-naming` | Defines the branch naming convention (`<type>/<issue>-<description>`) and creates properly named branches |

**Agents:**

| Agent | Model | Focus |
|-------|-------|-------|
| Commit Message | sonnet | Generates clear commit messages from diffs, ignoring formatting/linting noise |

### dev-swift

Swift-specific development tooling — code review and formatting/linting.

**Skills:**

| Skill | Command | Description |
|-------|---------|-------------|
| Review | `/dev-swift:review [paths]` | Spawns 6 specialized agents in parallel to analyze bugs, security, performance, Swift 6 compliance, code quality, and test coverage |

**Agents:**

| Agent | Model | Focus |
|-------|-------|-------|
| Bug Hunter | opus | Logic errors, nil crashes, race conditions, stability |
| Security Reviewer | sonnet | Secrets, injection, insecure storage, ATS, keychain |
| Performance Reviewer | sonnet | Retain cycles, allocations, O(n²), main thread blocking |
| Swift 6 Compliance | sonnet | Strict concurrency, typed throws, modern syntax |
| Code Quality | sonnet | Naming, SOLID, readability, dead code, API design |
| Test Reviewer | sonnet | Coverage gaps, assertion quality, flaky tests |
| Swift Lint & Format | sonnet | Runs SwiftFormat and SwiftLint, fixes issues in-place |

## Usage

Load plugins locally during development:

```sh
claude --plugin-dir ./development --plugin-dir ./dev-swift
```

Then use the slash commands:

```
# Development workflow
/development:commit              # format, lint, generate message, commit
/development:commit "Fix auth"   # format, lint, commit with given message

# Swift code review
/dev-swift:review                # review all Swift files
/dev-swift:review Sources/       # review a specific directory
```

## License

MIT
