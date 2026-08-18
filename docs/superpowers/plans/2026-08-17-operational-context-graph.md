# Operational Context Graph Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** Add a public-safe CMDB-as-code contract and make Graphify the authoritative consultation layer for the reviewed operational graph.

**Architecture:** YAML CI and relationship records persist the canonized graph beside human-readable Markdown runbooks and decisions. Graphify reads the reviewed repository revision as the query and navigation interface; live platforms execute actions and produce reconciliation observations. A dependency-free Bash validator enforces the static public-template contract without parsing live data.

**Tech Stack:** Markdown, YAML examples, Bash, Git, existing repository validation.

**Spec:** docs/superpowers/specs/2026-08-17-operational-context-graph-design.md

## Global Constraints

- Keep every public-template value a placeholder; do not add real domains, IPs, customer names, credentials, tokens, dumps, raw output, or secret values.
- Graphify is authoritative for consultation of the canonized graph at the reviewed revision; it is not an authorization engine.
- Declared and verified relationships require evidence and observed_at; inferred, ambiguous, conflict, and stale cannot independently guide an automatic action.
- Authorization and approval remain in an agent external profile; no relationship record may contain authority, direct_actions, approval_required, permission, or permissions fields.
- Do not require a live API, SSH, Graphify installation, hook, MCP server, Neo4j, or generated graph artifact in this public template.
- Preserve ASCII-only repository content and run scripts/validate-repo.sh plus git diff --check before every commit and before the pull request.

---

## File Structure

| Path | Responsibility |
| --- | --- |
| docs/shared/cmdb-policy.md | Canonized CI, relationship, provenance, confidence, and reconciliation policy |
| docs/guides/operational-context-graph.md | Graphify consultation/generation guide and external-profile separation |
| docs/templates/configuration-item.yaml | Machine-readable CI contract |
| docs/templates/configuration-relationship.yaml | Machine-readable edge contract |
| docs/templates/business-service.md | Human-facing business-service record mapped to CIs |
| docs/templates/change-record.md | Mutation intent/result record linked to CIs and relationships |
| docs/templates/reconciliation-observation.yaml | Sanitized post-execution or scheduled reconciliation record |
| examples/orgs/org-a/cmdb/ | Public-safe graph sample with CIs, relations, service, change, and reconciliation records |
| .graphifyignore | Sensitive and generated inputs excluded from Graphify extraction |
| scripts/validate-operational-graph.sh | Dependency-free static graph-contract validation |
| tests/operational-context-graph-test.sh | Red/green test fixture for the graph-contract validator |
| tests/run.sh | Executes the new test with existing shell tests |
| scripts/validate-repo.sh | Requires and runs the graph-contract validator |
| README.md, AGENTS.md, docs/index.md | Discoverability and agent operating contract |
| docs/shared/mutation-safety.md | Graph-first mutation and reconciliation rule |
| docs/guides/operational-branching.md | Graph evidence in operation and incident lifecycle |
| docs/dokploy-operations.md, docs/shared/README.md, docs/templates/runbook.md, examples/orgs/*/runbooks.md | Remove conflicting global approval instructions |

## Task 1: Build the static contract validator with a red-green test

**Files:**
- Create: tests/operational-context-graph-test.sh
- Create: scripts/validate-operational-graph.sh
- Modify: tests/run.sh
- Modify: scripts/validate-repo.sh

**Interfaces:**
- Consumes: a repository root as the optional first argument.
- Produces: exit code 0 for a complete safe graph contract; nonzero with a specific message for a missing file, missing Graphify ignore rule, missing required relationship field, or prohibited policy field.
- Command: scripts/validate-operational-graph.sh [repository-root]

- [ ] **Step 1: Write the failing contract test**

Create tests/operational-context-graph-test.sh. It creates a temporary fixture with all required contract files, a minimal relationship template, and .graphifyignore. It runs the validator once expecting success, appends approval_required: true to the relationship fixture, then requires a nonzero exit and an error naming approval_required.

~~~bash
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/docs/shared" "$fixture/docs/guides" "$fixture/docs/templates"
for path in docs/shared/cmdb-policy.md docs/guides/operational-context-graph.md docs/templates/configuration-item.yaml docs/templates/business-service.md docs/templates/change-record.md docs/templates/reconciliation-observation.yaml; do
  mkdir -p "$fixture/$(dirname "$path")"
  printf 'public-safe fixture\n' >"$fixture/$path"
done
cat >"$fixture/docs/templates/configuration-relationship.yaml" <<'EOF'
id: rel:example
from: ci:source
type: depends_on
to: ci:target
assertion: declared
status: canonical
observed_at: 2026-08-17T00:00:00Z
evidence:
  source: fixture
  reference: fixture/relationship
EOF
cat >"$fixture/.graphifyignore" <<'EOF'
.env*
.codex/
backups/
**/*.dump
**/evidence/raw/
graphify-out/
EOF
"$PROJECT_ROOT/scripts/validate-operational-graph.sh" "$fixture"
printf 'approval_required: true\n' >>"$fixture/docs/templates/configuration-relationship.yaml"
if "$PROJECT_ROOT/scripts/validate-operational-graph.sh" "$fixture" >"$fixture/out" 2>&1; then
  fail "rejects approval policy field"
else
  grep -Fq "approval_required" "$fixture/out" || fail "names prohibited field"
fi
~~~

- [ ] **Step 2: Run the new test to verify it fails**

Run: bash tests/operational-context-graph-test.sh

Expected: FAIL because scripts/validate-operational-graph.sh does not exist.

- [ ] **Step 3: Implement the smallest validator**

Create scripts/validate-operational-graph.sh. Its root selection avoids non-portable dependencies:

~~~bash
root="${1-}"
if [ -z "$root" ]; then
  root="$(cd "$(dirname "$0")/.." && pwd)"
fi
~~~

Require all eight graph files, exact Graphify ignore patterns, and relationship keys id, from, type, to, assertion, status, observed_at, evidence, source, and reference. Reject the policy-field expression below only in docs/templates and examples/orgs.

~~~bash
'^[[:space:]]*(authority|direct_actions|approval_required|permission|permissions)[[:space:]]*:'
~~~

- [ ] **Step 4: Run the test and existing test runner**

Run: bash tests/operational-context-graph-test.sh && tests/run.sh

Expected: PASS; the test observes both the valid fixture and rejected prohibited field, and Dokploy context tests remain green.

- [ ] **Step 5: Integrate the validator into repository validation**

Append tests/operational-context-graph-test.sh to tests/run.sh. Add scripts/validate-operational-graph.sh to shell syntax validation, to the required file list, and invoke it in scripts/validate-repo.sh after shell tests.

- [ ] **Step 6: Commit the validator milestone**

~~~bash
git add scripts/validate-operational-graph.sh scripts/validate-repo.sh tests/run.sh tests/operational-context-graph-test.sh
git commit -m "chore: validate operational graph contract"
~~~

## Task 2: Add the CMDB policy, templates, and public graph example

**Files:**
- Create: docs/shared/cmdb-policy.md
- Create: docs/templates/configuration-item.yaml
- Create: docs/templates/configuration-relationship.yaml
- Create: docs/templates/business-service.md
- Create: docs/templates/change-record.md
- Create: docs/templates/reconciliation-observation.yaml
- Create: examples/orgs/org-a/cmdb/README.md
- Create: examples/orgs/org-a/cmdb/cis/ragflow-business-service.yaml
- Create: examples/orgs/org-a/cmdb/cis/ragflow-application.yaml
- Create: examples/orgs/org-a/cmdb/cis/ragflow-postgres.yaml
- Create: examples/orgs/org-a/cmdb/cis/ragflow-server.yaml
- Create: examples/orgs/org-a/cmdb/cis/ragflow-monitor.yaml
- Create: examples/orgs/org-a/cmdb/relationships.yaml
- Create: examples/orgs/org-a/cmdb/business-services/ragflow.md
- Create: examples/orgs/org-a/cmdb/changes/CHG-2026-08-17-ragflow-redeploy.md
- Create: examples/orgs/org-a/cmdb/reconciliations/2026-08-17-ragflow-monitor.yaml
- Modify: examples/orgs/org-a/README.md

**Interfaces:**
- CI ids use ci:<kind>:<scope>:<slug>.
- Relationship ids use rel:<from-slug>:<type>:<to-slug>.
- Assertion values are declared, verified, inferred, or ambiguous.
- Status values are canonical, conflict, or stale.
- Reconciliation outcome values are match, added, changed, missing, stale, conflict, unverified, or redacted.

- [ ] **Step 1: Add the policy and templates**

Write docs/shared/cmdb-policy.md with source-of-truth boundaries, allowed CI and relationship fields, confidence meanings, lifecycle rules, no-secret rules, and reconciliation outcomes. Add the six templates with placeholders.

The relationship template contains these fields:

~~~yaml
id: rel:<from-slug>:<relationship-type>:<to-slug>
from: ci:<source-kind>:<scope>:<source-slug>
type: depends_on
to: ci:<target-kind>:<scope>:<target-slug>
assertion: declared
status: canonical
observed_at: <YYYY-MM-DDTHH:MM:SSZ>
evidence:
  source: <document|dokploy-api|cloudflare-api|ssh|checkmate-api>
  reference: <sanitized-reference>
  confidence: verified
~~~

- [ ] **Step 2: Add a connected public-safe RAGFlow graph**

Create five placeholder CIs and relations: business service delivered_by application; application depends_on Postgres, runs_on server, and monitored_by monitor. Add a Markdown business-service record linking the CI and relationship files so Graphify joins human and structured context.

- [ ] **Step 3: Add change and reconciliation examples**

The change record identifies graph revision, affected CIs/relationships, requested mutation, rollback plan, execution result, and reconciliation link. It has no approval field. The reconciliation record shows outcome match without raw output.

- [ ] **Step 4: Run the graph validator and inspect records**

Run: scripts/validate-operational-graph.sh && ! rg -n "authority:|direct_actions:|approval_required:|permission:|permissions:" docs/templates examples/orgs/org-a/cmdb

Expected: validator exits 0 and rg prints no matching fields.

- [ ] **Step 5: Commit the data-contract milestone**

~~~bash
git add docs/shared/cmdb-policy.md docs/templates examples/orgs/org-a
git commit -m "docs: add canonized CMDB graph contract"
~~~

## Task 3: Document Graphify as the authoritative query layer

**Files:**
- Create: docs/guides/operational-context-graph.md
- Create: .graphifyignore
- Modify: .gitignore
- Modify: README.md
- Modify: docs/index.md
- Modify: docs/shared/README.md
- Modify: docs/shared/dokploy-reference.md

**Interfaces:**
- Public template: Graphify setup and generated artifacts are optional.
- Private operations repo: reviewed graphify-out/graph.json, graph.html, and report can be versioned.
- Graph generation references the same checked-out repository revision as the consulted CMDB graph.

- [ ] **Step 1: Write the Graphify operating guide**

State the responsibility table, graph-first mutation flow, distinction between declared/verified and inferred/ambiguous, and transition to conflict/stale. Include copyable optional commands:

~~~bash
uv tool install graphifyy
graphify install --project --platform codex
graphify .
graphify query "what depends on ci:app:ragflow:production?"
~~~

Explain that project installation changes AGENTS.md and must be reviewed rather than run automatically by this template.

- [ ] **Step 2: Add Graphify exclusion and artifact policy**

Create .graphifyignore with the exact patterns tested in Task 1 plus .secrets/, secrets/, *.pem, *.key, id_rsa*, id_ed25519*, **/*.sql, **/*.bak, **/raw/, and graphify-out/. Add only graphify-out/cost.json and graphify-out/cache/ to .gitignore so reviewed graph artifacts remain versionable in private operations repositories.

- [ ] **Step 3: Add navigation links and source-of-truth language**

Update README.md, docs/index.md, docs/shared/README.md, and docs/shared/dokploy-reference.md. Add the CMDB policy, graph guide, and context CMDB path. Replace approval/preflight wording in README with graph consultation, external agent profile, execution verification, and reconciliation.

- [ ] **Step 4: Verify links and ignore contract**

Run: scripts/validate-repo.sh && git check-ignore -q graphify-out/cost.json && git check-ignore -q graphify-out/cache/example && ! git check-ignore -q graphify-out/graph.json

Expected: repository validation passes; cost/cache are ignored; graph.json is eligible for an intentional private-repository commit.

- [ ] **Step 5: Commit the Graphify integration milestone**

~~~bash
git add .gitignore .graphifyignore README.md docs/index.md docs/shared docs/guides/operational-context-graph.md
git commit -m "docs: integrate Graphify operational graph guidance"
~~~

## Task 4: Replace the repository-wide mutation authorization rule

**Files:**
- Modify: AGENTS.md
- Modify: docs/shared/mutation-safety.md
- Modify: docs/guides/operational-branching.md
- Modify: docs/dokploy-operations.md
- Modify: docs/templates/runbook.md
- Modify: examples/orgs/org-a/runbooks.md
- Modify: examples/orgs/org-b/runbooks.md
- Modify: docs/shared/backup-policy.md
- Modify: docs/shared/instance-backups.md

**Interfaces:**
- Before a mutation: query the reviewed Graphify graph.
- Declared/verified canonical relationship: external profile determines direct execution or approval request.
- After a mutation: record sanitized result and reconcile live divergence.
- No repository document imposes explicit human approval for all mutations.

- [ ] **Step 1: Replace mutation-safety sections**

Replace Actions Requiring Approval, Required Preflight, and Approval Format with Graph Consultation, Execution Preparation, External Agent Profile, and Reconciliation. Require graph revision, target CIs/relationships, evidence, backup posture, blast radius, rollback, verification plan, and result record. Do not require live CLI/MCP/API evidence before execution.

- [ ] **Step 2: Update agent and branch workflows**

In AGENTS.md, replace read-only discovery as a universal precondition with graph consultation and reconciliation. In operational branching, record graph revision and affected CI/relationship IDs; replace approval and live-discovery steps with the external-profile decision and post-operation observation. Preserve checkpoints, rollback, and public-safety rules.

- [ ] **Step 3: Remove conflicting approval language from runbooks and backup guidance**

Change the runbook template to consult the graph, record its revision, and execute according to the external profile. Change example runbooks and restore policies so they require appropriate capability and graph evidence rather than a universal human-approval statement.

- [ ] **Step 4: Search for contradictions and run full validation**

Run:

~~~bash
rg -n -i "mutating operations require explicit confirmation|ask for explicit approval before changing|approval captured for mutating|requires explicit approval for mutating|do not start a restore without explicit approval" README.md AGENTS.md docs examples
scripts/validate-repo.sh
git diff --check
~~~

Expected: contradiction search exits 1 with no matches; repository validation and diff check exit 0.

- [ ] **Step 5: Commit the mutation-policy milestone**

~~~bash
git add AGENTS.md docs/dokploy-operations.md docs/guides/operational-branching.md docs/shared/mutation-safety.md docs/shared/backup-policy.md docs/shared/instance-backups.md docs/templates/runbook.md examples/orgs/org-a/runbooks.md examples/orgs/org-b/runbooks.md
git commit -m "docs: make mutations graph-first"
~~~

## Task 5: Complete integration and prepare the PR

**Files:**
- Modify: docs/template-setup.md, docs/guides/operations-baseline.md, docs/shared/domain-policy.md, and docs/shared/instance.md only when the contradiction scan finds universal approval or mandatory live-discovery wording.
- Modify: docs/superpowers/plans/2026-08-17-operational-context-graph.md by checking completed implementation steps.

**Interfaces:**
- Validation fails when a public template removes a required graph contract artifact or adds a prohibited policy field to a graph template/example.
- Documentation points operators to Graphify for the canonized graph and to the external profile for approval.

- [ ] **Step 1: Search every remaining documentation conflict**

Run: rg -n -i "approval|required approval|explicit confirmation|read-only discovery before|current state.*CLI|before approval" README.md AGENTS.md docs examples

Classify each result as a valid external-profile reference, historical migration instruction, template transport setting, or contradiction. Edit each contradiction found in the listed files.

- [ ] **Step 2: Mark tasks complete and run full verification**

Run:

~~~bash
bash tests/operational-context-graph-test.sh
tests/run.sh
scripts/validate-operational-graph.sh
scripts/validate-repo.sh
git diff --check
git status --short
~~~

Expected: all commands exit 0; status lists only scoped graph-contract changes; the plan checklist marks implementation tasks complete.

- [ ] **Step 3: Review final diff against the spec**

Run:

~~~bash
git diff main...HEAD --check
git diff main...HEAD --stat
git diff main...HEAD -- README.md AGENTS.md docs/shared/mutation-safety.md scripts/validate-operational-graph.sh
~~~

Map every acceptance criterion in the spec to a changed file or a command result. Correct every omission before staging.

- [ ] **Step 4: Commit integration and publish the PR**

~~~bash
git add README.md AGENTS.md docs .gitignore .graphifyignore scripts tests examples
git commit -m "docs: complete operational context graph template"
git push -u origin agent/operational-context-graph
gh pr create --draft --base main --title "docs: add operational context graph template"
~~~

The PR body includes Summary, Canonized Graph Decision, Relationship Confidence, Authorization Boundary, Graphify Handling, Reconciliation Scope, Validation, and Follow-ups. It explicitly requests human validation and does not request automatic merge.
