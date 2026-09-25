#!/usr/bin/env bash
# Session startup for cx-agent-assist. Run from anywhere: ./scripts/start.sh
cd "$(dirname "$0")/.." || exit 1
echo "== cx-agent-assist session start =="

# 1. Docker engine
if ! docker info >/dev/null 2>&1; then
  echo "Starting Docker Desktop..."
  open -a Docker
  for i in {1..60}; do docker info >/dev/null 2>&1 && break; sleep 2; done
fi
docker info >/dev/null 2>&1 && echo "✓ Docker engine running" || { echo "✗ Docker did not start. Open Docker Desktop and check it."; exit 1; }

# 2. Database (once docker-compose.yml exists)
if [ -f docker-compose.yml ]; then
  docker compose up -d >/dev/null 2>&1 && echo "✓ Database container up" || echo "✗ docker compose up failed"
else
  echo "- No docker-compose.yml yet (skipping database)"
fi

# 3. GitHub + Git identity
gh auth status >/dev/null 2>&1 && echo "✓ GitHub signed in" || echo "✗ Not signed in: run gh auth login"
echo "  Git email: $(git config --global user.email)"

# 4. Latest code
git pull --ff-only >/dev/null 2>&1 && echo "✓ Code up to date" || echo "! git pull had an issue: run git status"

# 5. Secrets file
[ -f .env ] && echo "✓ .env present" || echo "- No .env yet"
git status --porcelain | grep -q "\.env$" && echo "✗ WARNING: .env is visible to Git!" 

# 6. Editor
code .
echo "== Ready =="
