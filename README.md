# Claude Code Plugins

A collection of plugins for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Plugins

### code-review-swift

Comprehensive Swift code review and commit tooling.

**Skills:**

| Skill | Command | Description |
|-------|---------|-------------|
| Review | `/code-review-swift:review [paths]` | Spawns 6 specialized agents in parallel to analyze bugs, security, performance, Swift 6 compliance, code quality, and test coverage |
| Commit | `/code-review-swift:commit [message]` | Runs SwiftFormat + SwiftLint, fixes issues, generates a commit message (if not provided), and commits |

**Review Agents:**

| Agent | Model | Focus |
|-------|-------|-------|
| Bug Hunter | opus | Logic errors, nil crashes, race conditions, stability |
| Security Reviewer | sonnet | Secrets, injection, insecure storage, ATS, keychain |
| Performance Reviewer | sonnet | Retain cycles, allocations, O(n²), main thread blocking |
| Swift 6 Compliance | sonnet | Strict concurrency, typed throws, modern syntax |
| Code Quality | sonnet | Naming, SOLID, readability, dead code, API design |
| Test Reviewer | sonnet | Coverage gaps, assertion quality, flaky tests |

## Usage

Load a plugin locally during development:

```sh
claude --plugin-dir ./code-review-swift
```

Then use the slash commands inside any Swift project:

```
/code-review-swift:review           # review all Swift files
/code-review-swift:review Sources/  # review a specific directory
/code-review-swift:commit            # format, lint, generate message, commit
/code-review-swift:commit "Fix auth" # format, lint, commit with given message
```

## License

MIT
