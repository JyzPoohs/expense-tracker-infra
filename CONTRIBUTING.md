# Contributing Guide — TorchEye Ledger

This document defines the mandatory Git workflow, branch strategy, commit conventions, and pull request process for the TorchEye Ledger project. All contributions must follow these standards without exception.

---

## Table of Contents

1. [Branch Strategy](#1-branch-strategy)
2. [Branch Naming](#2-branch-naming)
3. [Commit Message Format](#3-commit-message-format)
4. [Pull Request Process](#4-pull-request-process)
5. [Merge Strategy](#5-merge-strategy)
6. [Versioning](#6-versioning)
7. [Quick Reference](#7-quick-reference)

---

## 1. Branch Strategy

This project follows a simplified **GitFlow** model with two protected long-lived branches and short-lived feature branches.

```
main
 └── develop
      ├── feature/KAN-XX-scope-description
      ├── fix/KAN-XX-scope-description
      ├── hotfix/KAN-XX-scope-description   ← branches from main
      ├── release/vX.Y.Z                    ← branches from develop
      └── chore/KAN-XX-scope-description
```

### Branch Rules

| Branch | Source | Merges Into | Protected | Purpose |
|---|---|---|---|---|
| `main` | `release/*` or `hotfix/*` | — | ✅ Yes | Production-ready code only. Never commit directly. |
| `develop` | `main` (initial) | `main` via release | ✅ Yes | Integration branch. All features land here first. |
| `feature/*` | `develop` | `develop` | No | New functionality tied to a Jira story |
| `fix/*` | `develop` | `develop` | No | Bug fixes tied to a Jira task |
| `hotfix/*` | `main` | `main` + `develop` | No | Critical production fixes. Bypasses develop. |
| `release/*` | `develop` | `main` + `develop` | No | Release stabilisation. Only bug fixes allowed. |
| `chore/*` | `develop` | `develop` | No | Dependency updates, config, tooling |

### Rules for `main` and `develop`
- Direct commits are **blocked**. All changes go through Pull Requests.
- Merges require the PR checklist to be completed.
- `main` is only updated from `release/*` or `hotfix/*` branches.

---

## 2. Branch Naming

Format: `{type}/{jira-ticket}-{short-description}`

- Use **lowercase** only
- Use **hyphens** to separate words, never underscores or spaces
- Keep descriptions short and imperative (≤ 5 words)
- Always include the Jira ticket number

### Type Prefixes

| Prefix | When to Use |
|---|---|
| `feature/` | New feature (Story ticket) |
| `fix/` | Bug fix (Task ticket, To Fix status) |
| `hotfix/` | Critical production fix |
| `release/` | Release preparation |
| `chore/` | Maintenance, deps, config (no functional change) |
| `test/` | Adding or updating tests only |
| `docs/` | Documentation only |
| `refactor/` | Code restructuring without behaviour change |

### Examples

```bash
# ✅ Correct
feature/KAN-44-budget-entity-service
feature/KAN-51-redis-cache-setup
fix/KAN-76-txn-userid-filter-leak
fix/KAN-77-update-error-message
hotfix/KAN-76-critical-data-leak
chore/KAN-79-cors-env-config
test/KAN-73-integration-tests
docs/KAN-40-swagger-annotations
refactor/KAN-19-keycloak-jwt-converter
release/v2.0.0

# ❌ Wrong
KAN-44-budget                          # missing type prefix
feature/budget-entity                  # missing Jira ticket
feature/KAN-44_budget_entity_service   # underscores not allowed
Feature/KAN-44-Budget-Entity           # uppercase not allowed
feature/KAN-44                         # too vague, no description
```

---

## 3. Commit Message Format

This project uses **Conventional Commits** extended with Jira ticket references.

### Structure

```
<type>(<scope>): <subject> [KAN-XX]

[optional body]

[optional footer]
```

### Rules

| Field | Rule |
|---|---|
| **type** | Must be one of the allowed types (see table below) |
| **scope** | Must be one of the allowed scopes (see table below) |
| **subject** | Imperative mood · lowercase · no trailing period · max 72 chars |
| **Jira ticket** | Required at end of subject line: `[KAN-XX]` |
| **body** | Explain **why**, not what. Wrap at 72 chars. |
| **footer** | `Closes KAN-XX` to auto-close · `Ref KAN-XX` to link · `BREAKING CHANGE:` for breaking changes |
| **`!` marker** | Append `!` after type or scope to signal a breaking change |

### Allowed Types

| Type | When to Use | Maps to Commit Tag |
|---|---|---|
| `feat` | New functionality | feat |
| `fix` | Bug or defect fix | fix |
| `security` | Security-related change | security |
| `refactor` | Code restructuring, no behaviour change | refactor |
| `perf` | Performance improvement | perf |
| `test` | Adding or updating tests | test |
| `docs` | Documentation only | docs |
| `style` | Formatting, spacing, UI style (no logic change) | style |
| `chore` | Maintenance, tooling, dependency updates | chore |
| `build` | Build system, Docker, Kubernetes, CI/CD | build |
| `revert` | Reverts a previous commit | — |

### Allowed Scopes

| Scope | Layer | Description |
|---|---|---|
| `auth` | BE + FE | Authentication, Keycloak, JWT, security config |
| `user` | BE + FE | User entity, provisioning, profile |
| `txn` | BE + FE | Transaction CRUD, filtering, list |
| `category` | BE + FE | System and user categories, preferences |
| `dashboard` | BE + FE | Charts, summary cards, analytics |
| `budget` | BE + FE | Budget limits, comparison, alerts |
| `cache` | BE | Redis caching layer |
| `kafka` | BE | Event producers and consumers |
| `search` | BE + FE | Elasticsearch indexing and search |
| `ai` | BE + FE | AI advisor, LLM integration, insights |
| `k8s` | Infra | Kubernetes manifests, Helm, HPA |
| `infra` | Infra | Docker, Flyway, config, Actuator, Swagger |
| `fe` | FE | Frontend-only changes (routing, layout, UI) |
| `be` | BE | Backend-only cross-cutting changes |
| `e2e` | Test | End-to-end tests |

### Examples

```bash
# ✅ New feature
feat(budget): add budget entity, repository, and service layer [KAN-44]

# ✅ Bug fix — critical, with breaking change marker
fix(txn)!: add userId filter to getByType and getByCategory endpoints [KAN-76]

Closes KAN-76
BREAKING CHANGE: getByType and getByCategory now require authentication and
return only the authenticated user's transactions. Previously returned all
users' data — this was a data leak.

# ✅ Security fix
security(infra)!: rotate default Keycloak admin credentials [KAN-84]

Closes KAN-84

# ✅ Performance
perf(cache): cache dashboard chart responses with 5-minute TTL [KAN-52]

Invalidation triggered on any transaction write event.
Closes KAN-52

# ✅ Infrastructure
build(infra): add Redis service to Docker Compose [KAN-51]

Ref KAN-51

# ✅ Refactor with body
refactor(auth): extract KeycloakJwtAuthenticationConverter to dedicated class [KAN-19]

Previously inline in SecurityConfig. Extracted to improve testability
and single-responsibility compliance.

# ✅ Chore
chore(infra): move CORS origin to environment variable [KAN-79]

Replaces hardcoded localhost:5173 in SecurityConfig and TransactionController.
Closes KAN-79

# ✅ Tests
test(be): add Testcontainers integration tests for TransactionService [KAN-73]

Ref KAN-73

# ✅ Docs
docs(infra): add Swagger annotations to TransactionController [KAN-40]

# ✅ Revert
revert: feat(budget): add budget entity [KAN-44]

Reverts commit abc1234 due to migration conflict.

# ❌ Wrong — no type
add budget entity

# ❌ Wrong — no Jira ticket
feat(budget): add budget entity

# ❌ Wrong — past tense subject
feat(budget): added budget entity [KAN-44]

# ❌ Wrong — trailing period
feat(budget): add budget entity. [KAN-44]

# ❌ Wrong — subject too vague
fix: fix bug [KAN-76]

# ❌ Wrong — WHAT instead of WHY in body
feat(budget): add budget service [KAN-44]

Added BudgetService.java with create(), findByUser(), update(), delete() methods.
```

---

## 4. Pull Request Process

### Step-by-Step

```
1. Create branch from develop (or main for hotfix)
   git checkout develop && git pull origin develop
   git checkout -b feature/KAN-44-budget-entity-service

2. Develop locally with atomic commits
   git commit -m "feat(budget): add Budget entity and Flyway migration V2.02 [KAN-44]"
   git commit -m "feat(budget): add BudgetRepository with user-scoped queries [KAN-44]"
   git commit -m "feat(budget): add BudgetService with CRUD and monthly logic [KAN-44]"

3. Keep branch up to date (rebase, not merge)
   git fetch origin develop
   git rebase origin/develop

4. Push and open PR
   git push origin feature/KAN-44-budget-entity-service

5. Fill in PR template (see below)

6. Address review comments, push additional commits

7. Squash merge when approved

8. Delete branch after merge
```

### PR Title Format

Same as commit message format:

```
feat(budget): add budget entity, repository, and service layer [KAN-44]
```

### PR Template

Every PR must include:

```markdown
## Summary
<!-- One paragraph: what this PR does and why -->

## Jira Ticket
<!-- Link: https://jamie1331.atlassian.net/browse/KAN-XX -->

## Type of Change
- [ ] feat — new feature
- [ ] fix — bug fix
- [ ] security — security change
- [ ] refactor — code restructure
- [ ] perf — performance improvement
- [ ] test — tests only
- [ ] docs — documentation only
- [ ] build/chore — infrastructure or maintenance

## Checklist
- [ ] Branch name follows convention: `{type}/KAN-XX-description`
- [ ] All commits follow Conventional Commits format with Jira ticket
- [ ] Self-reviewed the diff before opening PR
- [ ] No debug logs, commented-out code, or TODO without a Jira ticket
- [ ] New/changed API endpoints are documented in Swagger
- [ ] Flyway migration added if schema changed (version follows sequence)
- [ ] Environment variables documented in README if added
- [ ] Tests added or updated for changed behaviour
- [ ] CORS, security config not weakened without justification

## Testing
<!-- How was this tested? Screenshots if UI change. -->

## Breaking Changes
<!-- List any breaking changes or write "None" -->
```

### PR Size Guidelines

| Size | Lines Changed | Guidance |
|---|---|---|
| Small | < 200 | Ideal. Fast to review. |
| Medium | 200–500 | Acceptable for a feature. |
| Large | 500–1000 | Split if possible. Add extra context. |
| X-Large | > 1000 | Must be split unless it's a generated file. |

---

## 5. Merge Strategy

| Branch Target | Strategy | Reason |
|---|---|---|
| `develop` ← `feature/*` | **Squash merge** | Clean linear history. One commit per feature. |
| `develop` ← `fix/*` | **Squash merge** | Same. |
| `develop` ← `chore/*` | **Squash merge** | Same. |
| `main` ← `release/*` | **Merge commit** | Preserves release boundary in history. |
| `main` ← `hotfix/*` | **Merge commit** | Preserves hotfix audit trail. |
| `develop` ← `hotfix/*` | **Cherry-pick** | Bring fix to develop without release merge. |

### Squash Merge Message Format

When squash-merging, the final commit message must follow Conventional Commits format:

```
feat(budget): add budget entity, repository, and service layer [KAN-44]

- Budget entity with user, category, amount, month, year fields
- BudgetRepository with user-scoped query methods
- BudgetService with monthly CRUD and overlap validation
- BudgetController with POST, GET, PUT, DELETE endpoints

Closes KAN-44
```

---

## 6. Versioning

This project follows **Semantic Versioning** (`vMAJOR.MINOR.PATCH`).

| Change Type | Version Bump | Example |
|---|---|---|
| Breaking change (`!` or `BREAKING CHANGE`) | MAJOR | v1.0.0 → v2.0.0 |
| New feature phase complete | MINOR | v1.0.0 → v1.1.0 |
| Bug fix or patch | PATCH | v1.0.0 → v1.0.1 |

### Phase-to-Version Mapping

| Version | Phase | Content |
|---|---|---|
| `v1.0.0` | PHASE-1 | Foundation: Auth, Transaction, Category, Dashboard, Infra ✅ |
| `v2.0.0` | PHASE-2 | Budget Management + Category Write |
| `v2.1.0` | PHASE-3 | Redis Caching |
| `v3.0.0` | PHASE-4 | Kafka Event Streaming |
| `v3.1.0` | PHASE-5 | Elasticsearch Search |
| `v4.0.0` | PHASE-6 | AI Financial Advisor |
| `v5.0.0` | PHASE-7 | Kubernetes & CI/CD |

### Release Process

```bash
# 1. Create release branch from develop
git checkout develop && git pull origin develop
git checkout -b release/v2.0.0

# 2. Bump version in pom.xml / package.json
# 3. Final regression testing
# 4. Fix only — no new features on release branch

# 5. Merge to main (merge commit, not squash)
git checkout main
git merge --no-ff release/v2.0.0 -m "release: v2.0.0 — Budget Management [PHASE-2]"

# 6. Tag
git tag -a v2.0.0 -m "v2.0.0 — Budget Management complete"
git push origin main --tags

# 7. Merge back to develop
git checkout develop
git merge --no-ff release/v2.0.0
git push origin develop

# 8. Delete release branch
git branch -d release/v2.0.0
```

---

## 7. Quick Reference

### Daily Workflow Cheatsheet

```bash
# Start a new feature
git checkout develop && git pull origin develop
git checkout -b feature/KAN-XX-short-description

# Stage and commit (atomic — one logical change per commit)
git add <specific-files>
git commit -m "feat(scope): imperative description [KAN-XX]"

# Keep up to date before pushing
git fetch origin develop
git rebase origin/develop

# Push
git push origin feature/KAN-XX-short-description

# After PR is merged — clean up
git checkout develop && git pull origin develop
git branch -d feature/KAN-XX-short-description
```

### Commit Type → Branch Type Mapping

| Commit Type | Branch Prefix |
|---|---|
| `feat` | `feature/` |
| `fix` | `fix/` |
| `security` | `fix/` or `hotfix/` |
| `refactor` | `refactor/` or `feature/` |
| `perf` | `feature/` |
| `test` | `test/` |
| `docs` | `docs/` |
| `style` | `feature/` |
| `chore` | `chore/` |
| `build` | `chore/` |

### What NOT to Do

```bash
# ❌ Never commit directly to main or develop
git checkout main && git commit ...

# ❌ Never force-push to main or develop
git push --force origin main

# ❌ Never use git merge on feature branches (use rebase)
git merge origin/develop  # use: git rebase origin/develop

# ❌ Never commit .env files or secrets
git add .env

# ❌ Never leave WIP commits in a PR
git commit -m "wip"
git commit -m "fix fix fix"

# ❌ Never merge without completing the PR checklist
```
