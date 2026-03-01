---
name: library-docs
description: >
  Fetch current documentation for any library or framework before using it.
  Use whenever writing, reviewing, or explaining code that involves an external
  library or framework — especially when the correct API, method signatures, or
  version-specific behaviour matters.
---

Before using, reviewing, or explaining any external library or framework:

1. Call `mcp__context7__resolve-library-id` with the library name to get its documentation ID.
2. Call `mcp__context7__query-docs` with that ID and a focused query to retrieve the relevant documentation.
3. Use the returned documentation as the authoritative source — do not rely on training data alone, as APIs change between versions.

Apply this to every library involved in the current task, not just the primary one.
