# Runbook: <procedure-name>

Scope: `<context-slug|global>`

Risk: `read-only|low|medium|high`

## Purpose

What this procedure accomplishes.

## Preconditions

- Session focus declared.
- Correct CLI wrapper or MCP server selected.
- Graphify revision, target CIs, and target relationships recorded when the
  procedure is mutating.
- Direct mutation uses only canonical `declared` or `verified` relationships
  with evidence and `observed_at`; other relationship states require
  investigation.
- Backup posture, blast radius, rollback path, and verification plan recorded.
- The agent's external profile determines direct execution, approval, or
  read-only behavior.

## Steps

1. Query Graphify at the recorded revision.
2. Record the relationship evidence used for the decision.
3. Apply the action according to the agent's external profile.
4. Verify result.
5. Create a sanitized reconciliation observation and update docs.

## Verification

| Check | Command/source | Expected result |
| --- | --- | --- |

## Rollback

How to revert or recover if the procedure fails.
