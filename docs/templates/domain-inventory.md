# Domain Inventory

| Field | Value |
| --- | --- |
| Domain | `<app.seudominio.com>` |
| Zone | `<seudominio.com>` |
| Cloudflare proxied | `<yes|no>` |
| Access protected | `<yes|no>` |
| Target host | `<NOME_DA_VPS_OU_PROJETO>-<NOME_DA_STACK>` |
| Compose | `<stack>-runtime` |
| Service | `<service-name>` |
| Internal port | `<port>` |
| Rollback DNS value | `<previous-value>` |

## Validation

```bash
curl -I https://<app.seudominio.com>
```
