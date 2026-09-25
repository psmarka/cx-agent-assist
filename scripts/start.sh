#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# start.sh: session startup for cx-agent-assist
# Normal use: open VS Code, press Control + ` for the terminal, then run:
#     ./scripts/start.sh
#
# What it does, in order:
#   1. Makes sure Docker's engine is running (starts Docker Desktop if not)
#   2. Starts the database container (once docker-compose.yml exists)
#   3. Checks you are signed in to GitHub and shows your Git email
#   4. Downloads any new commits from GitHub
#   5. Checks the .env secrets file exists and is NOT visible to Git
#   6. Opens the project in VS Code (skipped if you're already in it)
# Every step checks first and only acts if needed, so it is safe to run anytime.
#
# Flow:
#   start ─> cd to project ─> Docker running? ──no──> open Docker, wait
#                                   │yes
#                                   v
#            docker-compose.yml? ──yes──> start database container
#                                   v
#            GitHub signed in? ─> git pull ─> .env present & hidden? ─> Ready
#
# Shell symbols used below:
#   >/dev/null 2>&1   throw away the command's output and errors (keeps it tidy)
#   A && B            run B only if A succeeded
#   A || B            run B only if A failed
#   $( ... )          run the command inside and use its output as text
#   if [ -f file ]    true if that file exists
# ------------------------------------------------------------------------------

# The first line above (#!/usr/bin/env bash) tells macOS to run this file with bash.

# Move to the project folder, wherever this script was run from.
# $0 is this script's path; dirname gives its folder (scripts/); /.. goes up one
# level to the project root. If that fails, stop (exit 1 means "ended with error").
cd "$(dirname "$0")/.." || exit 1
echo "== cx-agent-assist session start =="

# --- 1. Docker engine ---------------------------------------------------------
# "docker info" only succeeds if the engine is running. The ! means "if NOT".
if ! docker info >/dev/null 2>&1; then
  echo "Starting Docker Desktop..."
  open -a Docker                       # launch the Docker Desktop app
  # Check every 2 seconds, up to 60 times (2 minutes), until the engine answers.
  for i in {1..60}; do
    docker info >/dev/null 2>&1 && break   # engine is up: leave the loop
    sleep 2
  done
fi
# Final check: report success, or explain and stop the script.
docker info >/dev/null 2>&1 \
  && echo "✓ Docker engine running" \
  || { echo "✗ Docker did not start. Open Docker Desktop and check it."; exit 1; }

# --- 2. Database --------------------------------------------------------------
# Only possible once docker-compose.yml (the database recipe) exists.
# "docker compose up -d" starts the container in the background, and does
# nothing if it is already running.
if [ -f docker-compose.yml ]; then
  docker compose up -d >/dev/null 2>&1 \
    && echo "✓ Database container up" \
    || echo "✗ docker compose up failed: run 'docker compose up -d' to see the error"
else
  echo "- No docker-compose.yml yet (skipping database)"
fi

# --- 3. GitHub sign-in and Git identity ---------------------------------------
# "gh auth status" succeeds only if the terminal is signed in to GitHub.
gh auth status >/dev/null 2>&1 \
  && echo "✓ GitHub signed in" \
  || echo "✗ Not signed in: run gh auth login"
# Show the email stamped on your commits (should be the noreply address).
echo "  Git email: $(git config --global user.email)"

# --- 4. Latest code -----------------------------------------------------------
# Download new commits from GitHub. --ff-only refuses to merge if your local
# history and GitHub's have diverged, so nothing gets combined by surprise.
git pull --ff-only >/dev/null 2>&1 \
  && echo "✓ Code up to date" \
  || echo "! git pull had an issue: run git status"

# --- 5. Secrets file ----------------------------------------------------------
# .env holds your API keys. It should exist (once created) and must never be
# visible to Git. "git status --porcelain" lists changed/untracked files in a
# simple format; grep -q quietly checks whether .env is among them.
[ -f .env ] && echo "✓ .env present" || echo "- No .env yet"
git status --porcelain | grep -q "\.env$" \
  && echo "✗ WARNING: .env is visible to Git! Check .gitignore before committing."

# --- 6. Editor ----------------------------------------------------------------
# VS Code's built-in terminal sets TERM_PROGRAM to "vscode". If we're already
# inside VS Code there's nothing to open. If you ran this from the Mac Terminal
# app instead, open the current folder (.) in VS Code.
if [ "$TERM_PROGRAM" != "vscode" ]; then
  code .
fi
echo "== Ready =="
