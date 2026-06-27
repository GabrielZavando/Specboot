# Skill: deploy

## Description

Release workflow for Node.js projects with Docker. Includes version bump, build, smoke tests, and rollback procedure.

**Use when:** Deploying to staging or production. Executed as `/deploy` or manually before a release.

## Prerequisites

- Docker installed and running
- Access to container registry (GHCR, Docker Hub, or private)
- `openspec` CLI installed
- Slack/Discord webhook for notifications (optional)

## Process — 8 Phases

### Phase 1: Pre-deploy Checklist

```bash
# 1. Verify all tests pass
npm test

# 2. Run linting
npm run lint

# 3. Run type checking
npm run typecheck

# 4. Verify build succeeds
npm run build

# 5. Check for security vulnerabilities
npm audit
```

**Exit criteria:** All checks pass. If any fails, fix before proceeding.

---

### Phase 2: Version Bump

Choose the bump type based on changes:

```bash
# Patch (bug fixes) — 1.0.0 → 1.0.1
npm version patch

# Minor (new features, backward compatible) — 1.0.0 → 1.1.0
npm version minor

# Major (breaking changes) — 1.0.0 → 2.0.0
npm version major
```

This creates:
- Git tag: `v1.2.3`
- Git commit: `release: v1.2.3`
- Updated `package.json` version

**Push the tag:**
```bash
git push origin v1.2.3
```

---

### Phase 3: Docker Build

```bash
# Build the image
docker build -t myapp:1.2.3 .

# Or with build args
docker build \
  --build-arg NODE_ENV=production \
  --build-arg API_URL=https://api.example.com \
  -t myapp:1.2.3 .
```

**Multi-stage Dockerfile example:**

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm ci --omit=dev
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

---

### Phase 4: Push to Registry

```bash
# GitHub Container Registry
docker tag myapp:1.2.3 ghcr.io/org/myapp:1.2.3
docker push ghcr.io/org/myapp:1.2.3

# Docker Hub
docker tag myapp:1.2.3 myorg/myapp:1.2.3
docker tag myapp:1.2.3 myorg/myapp:latest
docker push myorg/myapp:1.2.3
docker push myorg/myapp:latest
```

---

### Phase 5: Deploy to Staging

```bash
# Kubernetes
kubectl set image deployment/myapp app=myapp:1.2.3 -n staging

# Docker Compose (for simple setups)
sed -i 's/myapp:.*/myapp:1.2.3/' docker-compose.yml
docker-compose up -d

# SSH deployment
scp docker-compose.yml server:/opt/myapp/
ssh server "cd /opt/myapp && docker-compose pull && docker-compose up -d"
```

---

### Phase 6: Smoke Tests

Wait 30 seconds for the deployment to stabilize, then run smoke tests:

```bash
# Health check
curl -f https://staging.example.com/health || exit 1

# Key API endpoint
curl -f https://staging.example.com/api/v1/users || exit 1

# Run automated smoke tests
npm run test:smoke -- --env=staging
```

**If smoke tests fail:** Execute Phase 7 (Rollback) immediately.

---

### Phase 7: Deploy to Production

Only after staging smoke tests pass:

```bash
# Kubernetes (production namespace)
kubectl set image deployment/myapp app=myapp:1.2.3 -n production

# Or use a canary deployment strategy
kubectl apply -f k8s/canary.yaml
```

**Production smoke tests:**

```bash
npm run test:smoke -- --env=production
```

---

### Phase 8: Post-deploy

```bash
# Notify team (Slack example)
curl -X POST "$SLACK_WEBHOOK" \
  -H 'Content-Type: application/json' \
  -d '{"text":"✅ Deployed myapp:1.2.3 to production"}'

# Update changelog
npx standard-version --release-as 1.2.3

# Create GitHub release
gh release create v1.2.3 \
  --title "Release v1.2.3" \
  --notes "$(cat CHANGELOG.md | head -50)"
```

---

## Rollback Procedure

If something goes wrong post-deploy:

```bash
# Get previous version (from git tag or image registry)
PREV_VERSION=$(git describe --tags --abbrev=0)

# Kubernetes
kubectl rollout undo deployment/myapp -n production

# Docker Compose
docker-compose down
docker pull myorg/myapp:$PREV_VERSION
docker-compose up -d

# Verify rollback
curl -f https://production.example.com/health
```

---

## Environment Variables

Required for deploy:

| Variable | Description | Example |
|----------|-------------|---------|
| `DOCKER_REGISTRY` | Container registry URL | `ghcr.io/org` |
| `KUBECONFIG` | Path to kubeconfig (K8s) | `/~/.kube/config` |
| `SLACK_WEBHOOK` | Notification webhook | `https://hooks.slack.com/...` |

---

## Output Template

```markdown
## Deploy Report — v1.2.3

**Status:** ✅ SUCCESS / ❌ FAILED

### Timeline
- Pre-deploy checks: ✅
- Version bump: 1.2.2 → 1.2.3
- Docker image: ghcr.io/org/myapp:1.2.3
- Staging deploy: ✅
- Staging smoke tests: ✅
- Production deploy: ✅
- Production smoke tests: ✅

### Rollback command
kubectl set image deployment/myapp app=myapp:1.2.2 -n production
```