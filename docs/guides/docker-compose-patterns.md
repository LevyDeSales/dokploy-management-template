# Docker Compose Patterns for Dokploy

Dokploy can run Docker Compose and Docker Stack style deployments. Keep compose
files public-safe and repeatable.

## Environment Variables

Dokploy writes variables from the Environment tab to a `.env` file next to the
compose file. The compose must explicitly consume those values.

Use `env_file`:

```yaml
services:
  app:
    image: ghcr.io/example-org/example-app:1.0.0
    env_file:
      - .env
```

Or reference specific variables:

```yaml
services:
  app:
    image: ghcr.io/example-org/example-app:1.0.0
    environment:
      DATABASE_URL: ${DATABASE_URL}
```

## Volumes

| Option | Use when |
| --- | --- |
| Docker named volume | You need Docker-managed persistence and volume backups |
| `../files` bind mount | You need host-readable simple files |
| Object storage | You store large user uploads or attachments |

Do not mount files directly from the repository clone for data that must
survive deployments.

## Compose Rules

- Use explicit image tags in production.
- Avoid `latest`.
- Avoid `container_name` unless documented.
- Do not publish database or Redis ports to the public internet.
- Use healthchecks when images support them.
- Keep labels and domains consistent with Dokploy routing.
- Keep real secrets out of examples.

## Examples

- `examples/docker-compose/app.dokploy.yml`
- `examples/docker-compose/postgres-redis.dokploy.yml`
- `examples/env/app.env.example`

## Official Docs

- https://docs.dokploy.com/docs/core/docker-compose
