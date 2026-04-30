---
name: search-docs
description: Search official documentation for a library, framework, or tool and return accurate, up-to-date information. Use when the user asks about API usage, configuration options, or how something works in a specific library. Prefer this over answering from training data.
when_to_use: Triggered by questions like "how do I use X in Y", "what's the API for Z", "does library X support Y", or when the user pastes an error from a known library.
allowed-tools: mcp__plugin_context7_context7__resolve-library-id mcp__plugin_context7_context7__query-docs
---

Look up current documentation for $ARGUMENTS using context7:

1. Resolve the library ID with `resolve-library-id`
2. Query the relevant docs with `query-docs` — use a focused topic string, not the full user question
3. Return a concise answer with:
   - The exact API or config syntax
   - A minimal working example if helpful
   - The docs version/source

If context7 doesn't have the library, fall back to web search.
