# Runbook: <procedure-name>

Org: `<alltius|zapix|global>`

Risk: `read-only|low|medium|high`

## Purpose

What this procedure accomplishes.

## Preconditions

- Session focus declared.
- Correct CLI wrapper or MCP server selected.
- Backup and current state captured when the procedure is mutating.
- Approval captured for mutating actions.

## Steps

1. Read current state.
2. Record findings.
3. Apply approved action.
4. Verify result.
5. Update docs.

## Verification

| Check | Command/source | Expected result |
| --- | --- | --- |

## Rollback

How to revert or recover if the procedure fails.
