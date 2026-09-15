# TorchEye Ledger — Infrastructure

Docker Compose setup for local development. Runs MySQL 8 and Keycloak 26 with automatic database initialisation and realm import. All service ports and credentials are managed via environment variables.

> **Repositories:** [Frontend](https://github.com/JyzPoohs/expense-tracker-react) · [Backend](https://github.com/JyzPoohs/expense-tracker) · [Infrastructure](https://github.com/JyzPoohs/expense-tracker-infra)

---

## Services

| Service | Image | Host Port | Container Port | Purpose |
|---|---|---|---|---|
| `mysql` | `mysql:8.0` | `3307` | `3306` | Shared database |
| `keycloak` | `quay.io/keycloak/keycloak:26.6.1` | `1880` | `8080` | Identity and access management |

Ports are configurable via `.env` (see Environment Variables below).

---

## Directory Structure

```
expense-tracker-infra/
├── docker-compose.yml
├── .env.example              # Copy to .env and fill in secrets
├── keycloak/
│   └── import/
│       └── expense-realm.json   # Pre-configured Keycloak realm
└── mysql/
    └── init/
        └── init.sql             # DB and user bootstrap script
```

---

## Quick Start

### Prerequisites
- Docker Desktop (or Docker Engine + Compose plugin)

### First-time setup

```bash
cp .env.example .env
# Edit .env — fill in all required secret values
```

### Start all services

```bash
docker compose up -d
```

### Stop all services

```bash
docker compose down
```

### Full reset (removes all data)

```bash
docker compose down -v
```

---

## Environment Variables

Copy `.env.example` to `.env` and set all values before starting:

| Variable | Description |
|---|---|
| `MYSQL_ROOT_PASSWORD` | MySQL root password |
| `KC_DB_USERNAME` | Keycloak database user |
| `KC_DB_PASSWORD` | Keycloak database password |
| `KC_ADMIN_USERNAME` | Keycloak bootstrap admin username |
| `KC_ADMIN_PASSWORD` | Keycloak bootstrap admin password |
| `MYSQL_HOST_PORT` | MySQL host port (default: `3307`) |
| `KEYCLOAK_HOST_PORT` | Keycloak host port (default: `1880`) |

> No secrets should ever be committed to source control. The `.env` file is gitignored.

---

## Database Setup

`init.sql` runs automatically on first container start and creates:

| Database | Purpose |
|---|---|
| `expense_app_db` | Application data (users, transactions, categories, budgets) |
| `keycloak_db` | Keycloak internal state |

MySQL is exposed on port `3307` (not `3306`) to avoid conflicts with a locally installed MySQL instance.

---

## Keycloak Setup

The realm `expense-realm` is imported automatically from `keycloak/import/expense-realm.json` on startup. Includes:

- RS256 token signing
- Pre-configured client for the React frontend (PKCE flow)
- `ROLE_USER` and `ROLE_ADMIN` role mappings
- Access token lifetime: 300 seconds

Keycloak Admin Console: `http://localhost:1880`

> Admin credentials are set via `KC_ADMIN_USERNAME` / `KC_ADMIN_PASSWORD` in `.env`.
> Never use default credentials in any non-local environment.

---

## Service URLs

| Service | URL |
|---|---|
| Keycloak Admin Console | `http://localhost:1880` |
| Keycloak Realm Endpoint | `http://localhost:1880/realms/expense-realm` |
| MySQL | `localhost:3307` |

---

## Service Configuration Notes

- **Healthcheck**: MySQL container has a healthcheck configured. Keycloak waits for MySQL to be healthy before starting (`depends_on: condition: service_healthy`).
- **Restart policy**: Both services use `restart: unless-stopped`.
- **Realm auto-import**: Keycloak imports the realm on first start. If the realm already exists, the import is skipped.

---

## Roadmap

### Phase 2 — Additional Services
- [ ] Redis container (for backend caching — KAN-51)
- [ ] Kafka + Zookeeper (for event streaming — KAN-54)
- [ ] Elasticsearch (for transaction search — KAN-57)

### Phase 3 — Kubernetes
- [ ] Migrate services to Kubernetes manifests (KAN-65)
- [ ] Helm charts per service (KAN-66)
- [ ] Persistent volume claims for MySQL
- [ ] Keycloak HA deployment
- [ ] Ingress controller with TLS

### Phase 4 — CI/CD
- [ ] GitHub Actions pipeline: build → test → push image → deploy (KAN-68)
- [ ] Environment-specific configs (dev / staging / prod)
- [ ] Secrets management (Kubernetes Secrets or Vault)
