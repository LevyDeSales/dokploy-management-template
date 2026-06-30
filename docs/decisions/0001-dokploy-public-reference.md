# ADR 0001: Public Dokploy Infrastructure Reference

## Status

Accepted.

## Context

Operators need a public, reusable reference for documenting and replicating a
small Dokploy-based infrastructure without exposing private hostnames, IPs,
tokens or customer context.

## Decision

This repository stores generic architecture, installation, migration, backup,
networking and operations documentation using placeholders.

Private repos may copy this structure and replace placeholders with real values.

## Consequences

- Public docs remain shareable with other operators and AI agents.
- Private operational state stays outside the public repository.
- Templates become the bridge between public guidance and private deployment.
