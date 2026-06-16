# Variable Policy

Use this policy to document variables without leaking secrets.

## Levels

Dokploy variables can be defined at these levels:

| Level | Use for | Docs path |
| --- | --- | --- |
| Project | Shared values reused by services in a project | `docs/orgs/<org>/projects/<project-slug>/variables.md` |
| Environment | Stage-specific overrides such as production vs staging | `docs/orgs/<org>/projects/<project-slug>/environments/<environment>.md` |
| Service | Service-specific values and overrides | Service docs under `services/` |

## Reference Syntax

- Project reference: `${{project.VARIABLE_NAME}}`
- Environment reference: `${{environment.VARIABLE_NAME}}`
- Service self-reference: `${{VARIABLE_NAME}}`

## Documentation Rules

- Document variable names, purpose, scope, owner, and rotation notes.
- Do not document secret values.
- Do not add a value column to Git-tracked docs.
- Use `Sensitive`, `Value present in Dokploy`, owner, rotation notes, and `Referenced by` fields instead of recording values.
- Record whether a variable is required for build time, runtime, or both.
- For Docker Compose, document whether variables are injected with `env_file: .env` or referenced explicitly with `${VAR_NAME}`.

## Review Checklist

- Shared credentials are not duplicated across services without a reason.
- Environment-specific values live at environment level, not project level.
- Production-only secrets are not reused in staging.
- Rotation owner and blast radius are documented for sensitive variables.
