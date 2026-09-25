# Setup Checklist: cx-agent-assist

A living record of every setup step for this project: what it is, why it matters, and how to verify it.
Update this file whenever a step is added or changed, then commit it.

**How to use it**

| Situation | Start at |
|---|---|
| New project on this Mac | Section 3 |
| New computer | Section 1 |
| Starting a work session | Section 4 (or run `./scripts/start.sh`) |

Status key: ✅ done · ⬜ not yet · ➖ optional / skipped

---

## 1. Once per computer

| Status | Step | Command | Why | Verify |
|---|---|---|---|---|
| ✅ | Apple developer tools | `xcode-select --install` | Provides Git and compilers | `git --version` |
| ✅ | Homebrew | Install script from brew.sh, then run the "Next steps" lines it prints | Mac package manager for everything below | `brew --version` |
| ✅ | Rosetta | `softwareupdate --install-rosetta --agree-to-license` | Install before Docker to avoid its setup error | Prints "finished successfully" |
| ✅ | GitHub CLI + uv | `brew install gh uv` | `gh` talks to GitHub. `uv` manages Python and packages | `gh --version`, `uv --version` |
| ✅ | VS Code + Docker Desktop | `brew install --cask visual-studio-code docker-desktop` | Editor, and the container engine | `code --version`, `docker --version` |
| ✅ | Docker first run | `open -a Docker` → accept terms → recommended settings → skip sign-in | Engine must be initialized once | `docker run --rm hello-world` |
| ✅ | GitHub sign-in | `gh auth login` → GitHub.com → HTTPS → Yes → web browser | Lets Git push without passwords | `gh auth status` |
| ✅ | Git identity | `git config --global user.name "Mark Aguilar"`<br>`git config --global user.email "$(gh api user --jq '"\(.id)+\(.login)@users.noreply.github.com"')"`<br>`git config --global init.defaultBranch main` | Commits are labeled with your name and private noreply email | `git config --global --list` |

## 2. Once per person (accounts)

| Status | Account | Why | Notes |
|---|---|---|---|
| ✅ | GitHub | Code hosting and portfolio | Settings → Emails: "Keep my email addresses private" + "Block command line pushes that expose my email" |
| ✅ | Docker | Optional | Not linked to GitHub. Not needed for this project |
| ⬜ | OpenAI | Embeddings (+ chat model option) | Set a usage limit before creating a key |
| ➖ | Anthropic | Optional chat model | Set a spend limit before creating a key |
| ⬜ | LangSmith | Tracing and evals | Can sign up with GitHub |

Keys are shown once. Store them in a password manager. Never paste them into chat, GitHub, or a terminal command.

## 3. Once per project

| Status | Step | Command | Why | Verify |
|---|---|---|---|---|
| ✅ | Projects folder | `mkdir -p ~/Projects && cd ~/Projects` | One home for all repos | `pwd` |
| ✅ | Create repo | `gh repo create cx-agent-assist --public --clone --gitignore Python --license mit --add-readme --description "..."` | Creates on GitHub and clones to Mac in one step | `ls -la` shows .git, .gitignore, LICENSE, README.md |
| ✅ | Python project | `uv init --python 3.12` | Creates pyproject.toml, .python-version, src/ layout | Files exist |
| ✅ | Packages | `uv add pandas langchain langgraph langsmith langchain-anthropic langchain-openai "psycopg[binary]" pgvector sqlalchemy pydantic faker python-dotenv` | Quote `"psycopg[binary]"` or zsh errors | `uv run python -c "import pandas; print(pandas.__version__)"` |
| ✅ | Secrets ignored | `grep -nE "^\.env\|^\.venv" .gitignore` | API keys and the environment never reach GitHub | Shows .env and .venv lines |
| ✅ | First commit | `git add .` → `git commit -m "..."` → `git push` | Baseline on GitHub | Visible on github.com |
| ⬜ | Database definition | Create `docker-compose.yml` (pgvector/pgvector:pg17) | Reproducible database anyone can start | File exists |
| ⬜ | Start DB + pgvector | `docker compose up -d`<br>`docker compose exec db psql -U app -d northpeak -c "CREATE EXTENSION IF NOT EXISTS vector;"` | Extension is enabled once per database | Query pg_extension shows `vector` |
| ⬜ | Secrets file | `code .env` (keys) + committed `.env.example` (names only) | Keys stay local. Template shows what's needed | `git status` never lists .env |
| ⬜ | Startup script | `scripts/start.sh` + `chmod +x scripts/start.sh` | Automates Section 4 | `./scripts/start.sh` runs clean |

## 4. Every session

Run `./scripts/start.sh` from the project folder, or do it by hand:

| Step | Command | Why |
|---|---|---|
| Start Docker | `open -a Docker`, wait for "Engine running" | Database runs in Docker |
| Go to project | `cd ~/Projects/cx-agent-assist` | Commands run from here |
| Start database | `docker compose up -d` | Harmless if already running |
| Get latest | `git pull` | Needed if you work on more than one machine |
| Open editor | `code .` | |

## 5. While working

| When | Command |
|---|---|
| What changed? | `git status` (.env must never appear) |
| Save progress | `git add .` → `git commit -m "what you did"` → `git push` |
| New package | `uv add <package>` |
| Run code | `uv run python <file>` |
| Gate passed | `git tag module-N && git push --tags` |
| DB status | `docker compose ps` |
| End of session | Commit + push. Optional: `docker compose stop`, quit Docker |

## 6. Troubleshooting (seen on this Mac)

| Symptom | Fix |
|---|---|
| `brew: command not found` after install | Run the "Next steps" lines Homebrew printed |
| Docker: Rosetta / "Internal Virtualization error" | Restart Mac, install Rosetta via softwareupdate, or continue without it |
| `failed to connect to the docker API ... docker.sock` | Docker Desktop isn't running. Open it and wait. If path is /var/run/docker.sock: `docker context use desktop-linux` |
| Docker Desktop won't open | Restart Mac → `brew uninstall --cask --zap --force docker-desktop` → remove leftovers → reinstall |
| brew asks for Full Disk Access | System Settings → Privacy & Security → Full Disk Access → Terminal, then Cmd+Q Terminal and reopen |
| `gh auth login` asks for Hostname | Picked "Other." Control+C and choose GitHub.com |
| zsh: no matches found (brackets) | Quote the argument, e.g. `"psycopg[binary]"` |

## 7. Change log

| Date | Change |
|---|---|
| 2026-09-24 | Machine setup, Docker clean reinstall, GitHub sign-in, Git identity |
| 2026-09-25 | Repo created, uv project + packages, first commit, this checklist added |
