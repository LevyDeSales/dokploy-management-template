# Portainer VPS Agent Readiness

| Field | Value |
| --- | --- |
| Date | `<YYYY-MM-DD>` |
| Host name | `<NOME_DA_VPS_OU_PROJETO>-<NOME_DA_STACK>` |
| Current owner | `Portainer` |
| Target owner | `Dokploy remote deployment server` |
| Panel host | `<NOME_DA_VPS_OU_PROJETO>-Panel` |
| SSH path | `<public-ip|private-ip|tailscale-ip>` |
| SSH user | `root` |
| SSH port | `<PORTA>` |
| Private network | `<provider-private-network|tailscale|vpn|none>` |
| Public HTTP ports | `80/tcp, 443/tcp` |
| Portainer status after migration | `<keep|remove-after-observation>` |

## Host Preflight

- [ ] OS updates applied.
- [ ] Bash available for the Dokploy SSH user.
- [ ] SSH key auth works.
- [ ] Root access works for the Dokploy setup path.
- [ ] Provider firewall reviewed.
- [ ] UFW/firewalld reviewed.
- [ ] Tailscale/private network configured when needed.
- [ ] Docker version recorded.
- [ ] Current containers recorded.
- [ ] Current volumes recorded.
- [ ] Current networks recorded.

## Portainer Inventory

| Stack | Compose source | Ports | Volumes | Database | Target owner |
| --- | --- | --- | --- | --- | --- |
| `<stack>` | `<git|web-editor|upload>` | `<ports>` | `<volumes>` | `<database>` | `<portainer|dokploy>` |

## Backup Evidence

| Item | Evidence |
| --- | --- |
| Host snapshot | `<snapshot-id-or-path>` |
| Portainer data backup | `<backup-id-or-path>` |
| Database dumps | `<backup-id-or-path>` |
| Volume archives | `<backup-id-or-path>` |
| Bind mount archives | `<backup-id-or-path>` |
| Restore test | `<result>` |

## Panel Registration Readiness

- [ ] Host should not receive a full Dokploy panel install.
- [ ] Host should be added as a Dokploy deployment server.
- [ ] Dokploy panel SSH key is planned.
- [ ] Host IP for panel registration is selected.
- [ ] No production DNS points to an untested Dokploy stack.
- [ ] First low-risk stack selected.

## Cutover Notes

```text
planned maintenance window:
first stack to migrate:
rollback command summary:
operator:
```
