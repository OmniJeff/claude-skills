---
name: gh-issue-writer
description: Write high-quality GitHub issues following a consistent structure. Use when creating or rewriting GitHub issues for any project. The skill enforces a standard format with: problem statement, background context, proposed solution or approach, definition of done, and a thorough test plan covering unit tests, integration tests, E2E tests, and manual verification. Triggers on phrases like "create a gh issue", "write up a github issue", "add this to the backlog", "open an issue for", "document this as an issue".
---

# GitHub Issue Writer

Write clear, well-structured GitHub issues that give implementers everything they need to understand, build, and verify the work.

## Issue structure

Every issue must include these sections in order:

### 1. Background (if not obvious)
One or two paragraphs of context. What is the current state? Why does this matter? What exists already that is relevant?

### 2. Problem / Goal
What is broken or missing? State it plainly. One clear sentence if possible.

### 3. Proposed approach (for features/changes)
How should it be solved? Be specific enough to guide implementation but not so prescriptive that it removes judgment. Include:
- Architecture decisions that have been agreed upon
- Key components or interfaces to implement
- Configuration/env vars if applicable
- What is explicitly out of scope

### 4. Definition of done
A checkbox list. Each item is a concrete, verifiable condition. Not vague ("it works") but specific ("POST /api/items returns 201 and the item appears in the watchlist").

### 5. Test plan
A checkbox list covering:
- **Unit tests**: mock dependencies, test logic in isolation
- **Integration tests**: real services, verify system behavior end-to-end
- **E2E tests**: browser/Playwright tests where applicable (these are the gold standard)
- **Manual verification**: steps a human should check that automation can't easily cover

## Quality bar

- Every claim in the issue should be accurate. If uncertain, say so.
- Avoid wording confusion — if a section conflates two different concepts, rewrite it.
- Use precise language. "The discovery scheduler" not "it".
- Link to related issues when they exist.
- The issue should be useful to an implementer who has no prior context.

## Anti-patterns to avoid

- Vague acceptance criteria ("it should work well")
- Missing test plan or test plan that only covers happy path
- Conflating different types of sources, services, or approaches without distinguishing them
- Proposing paid-API-only solutions without considering free alternatives
- Mentioning limits that don't apply (e.g. "no quota" for headless browsers vs. API rate limits)

## Workflow

1. Gather requirements from the user — ask clarifying questions if the scope is unclear
2. Draft the issue following the structure above
3. Review for coherence: does each section follow logically from the previous?
4. Create with `gh issue create --title "..." --body-file /tmp/issue_body.md`
   - Write the body to a temp file first to avoid shell escaping issues
5. Share the URL with the user

## Tips

- Write body content to `/tmp/issue_body.md` then use `--body-file` — never inline the body as a shell argument
- Use `gh issue edit <number> --body-file /tmp/issue_body.md` to rewrite an existing issue
- Checkbox syntax in GitHub markdown: `- [ ] item`
- Link related issues: "Depends on #10" or "Part of #22"
