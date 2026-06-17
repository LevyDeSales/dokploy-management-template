# Domain: <host><path>

Context: `<context>`

Project:

Environment:

Service:

## Routing

| Field | Value |
| --- | --- |
| Host |  |
| Path | `/` |
| Internal path |  |
| Strip path |  |
| Container port |  |
| HTTPS |  |
| Certificate |  |
| DNS provider |  |
| DNS target |  |
| Detail owner |  |
| Last observed |  |
| Source command/tool |  |

## Change Notes

- Application domains can update without service redeploy.
- Docker Compose domains require redeploy to apply Traefik labels.
- Path rewrite settings must be tested for redirects and absolute URLs.

## Verification

| Check | Result | Date |
| --- | --- | --- |
| DNS resolves |  |  |
| HTTPS valid |  |  |
| Route reaches service |  |  |
