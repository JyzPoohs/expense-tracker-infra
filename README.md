# TorchEye Ledger — Infrastructure

Docker Compose setup for local development. Runs MySQL 8 and Keycloak 26, with automatic database initialization and realm import.

> **Repositories:** [Frontend](https://github.com/JyzPoohs/expense-tracker-react) · [Backend](https://github.com/JyzPoohs/expense-tracker) · [Infrastructure](https://github.com/JyzPoohs/expense-tracker-infra)

---

## Services

| Service | Image | Port | Purpose |
|---|---|---|---|
| `mysql` | `mysql:8.0` | `3307:3306` | Shared database instance |
| `keycloak` | `keycloak:26.6.1` | `8080:8080` | Identity and access management |

---

## Directory Structure

```
expense-tracker-infra/
├── docker-compose.yml
├── keycloak/
│   └── import/
│       └── expense-realm-realm.json   # Pre-configured Keycloak realm
└── mysql/
    └── init/
        └── init.sql                   # DB and user bootstrap script
```

---

## Database Setup

`init.sql` runs automatically on first container start and creates:

| Database | Owner | Purpose |
|---|---|---|
| `expense_app_db` | `expenseuser` | Application data (users, transactions, categories) |
| `keycloak_db` | `expenseuser` | Keycloak internal state |

MySQL is exposed on port `3307` (not `3306`) to avoid conflicts with a locally installed MySQL instance.

---

## Keycloak Setup

The realm `expense-realm` is imported from `keycloak/import/expense-realm-realm.json` on startup. It includes:

- Realm configuration with RS256 token signing
- Pre-configured client for the React frontend
- Role mappings for `ROLE_USER` and `ROLE_ADMIN`
- Access token lifetime: 300 seconds

Keycloak admin console: `http://localhost:8080`
Default admin credentials: `admin / admin` *(change before any non-local deployment)*

---

## Quick Start

### Prerequisites

- Docker Desktop (or Docker Engine + Compose plugin)

### Start all services

```bash
docker compose up -d
```

### Stop all services

```bash
docker compose down
```

### Stop and remove volumes (full reset)

```bash
docker compose down -v
```

---

## Service URLs

| Service | URL |
|---|---|
| Keycloak Admin Console | `http://localhost:8080` |
| Keycloak Realm Endpoint | `http://localhost:8080/realms/expense-realm` |
| MySQL | `localhost:3307` |

---

## Roadmap

### Phase 2 — Additional Services
- [ ] Redis container (for backend caching)
- [ ] Kafka + Zookeeper (for event streaming)
- [ ] Elasticsearch (for transaction search)

### Phase 3 — Kubernetes
- [ ] Migrate all services to Kubernetes manifests
- [ ] Helm charts for each service
- [ ] Persistent volume claims for MySQL and Elasticsearch
- [ ] Keycloak HA deployment
- [ ] Ingress controller with TLS

### Phase 4 — CI/CD
- [ ] GitHub Actions pipeline (build → test → push image → deploy)
- [ ] Environment-specific configs (dev / staging / prod)
- [ ] Secrets management (Kubernetes Secrets or Vault)
