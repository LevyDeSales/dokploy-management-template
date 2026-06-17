# Domain Policy

Use this policy when documenting or changing Dokploy domains.

## Required Fields

Record these fields for every domain. Rollup tables may link to a per-domain detail doc when the full field set would make the table hard to scan.

| Field | Required | Example |
| --- | --- | --- |
| Organization/context | Yes | `org-a`, `org-b`, or your real context slug |
| Project | Yes | Dokploy project name |
| Environment | Yes | Runtime environment |
| Service | Yes | Application or Docker Compose service |
| Host | Yes | Public domain |
| Path | Yes | Use `/` when root |
| Internal path | If configured | Explain why it exists |
| Strip path | If configured | Note redirect risk |
| Container port | Yes | Traefik target port, not public exposure |
| HTTPS/certificate | Yes | LetsEncrypt, custom certificate, or none |
| DNS owner | Yes | DNS provider or internal owner |
| DNS target | Yes | IP, CNAME, load balancer, or provider record target |
| Verification date | Yes | Date of last check |

## Application vs Docker Compose

- Application domain changes can be applied through Dokploy and Traefik without redeploying the application.
- Docker Compose domain changes are represented through Traefik labels and require a redeploy before Traefik reads the new labels.
- For Docker Compose, document whether the service uses standard compose or Docker Stack mode.

## Safety Rules

- Confirm DNS target before changing a production domain.
- Confirm backup and rollback posture before changing production routing.
- Follow `docs/shared/mutation-safety.md` before changing live routing.
- Avoid path rewrites unless the application is known to support them.
- Do not use Advanced -> Ports as a substitute for normal domain routing unless the exposure is intentional and documented.
