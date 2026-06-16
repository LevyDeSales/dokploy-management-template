# Variables: <scope-name>

Org: `<alltius|zapix>`

Scope: `project|environment|service`

## Variables

Do not store secret values. Use `Value present in Dokploy` only as a yes/no status.

| Name | Purpose | Level | Sensitive | Value present in Dokploy | Referenced by | Rotation owner | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

## Reference Patterns

- Project variable: `${{project.NAME}}`
- Environment variable: `${{environment.NAME}}`
- Service variable: `${{NAME}}`
- Docker Compose explicit variable: `${NAME}`

## Review

| Check | Status | Notes |
| --- | --- | --- |
| No secret values in Git |  |  |
| Production and staging separated |  |  |
| Rotation owner known |  |  |
| Unused variables reviewed |  |  |
