# ─── User settings ───────────────────────────────────────────────────────────
GITHUB_USER ?= windikite

# Get your repo-root folder name (not the full mount path), dash-ify & lowercase it
RAW_NAME := $(shell basename "$(shell git rev-parse --show-toplevel 2>/dev/null)")
REPO_NAME := $(shell echo $(RAW_NAME) \
                  | tr ' ' '-' \
                  | tr '[:upper:]' '[:lower:]')

# current git branch, or default to main
BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)


# ─── Export & push ────────────────────────────────────────────────────────────
.PHONY: export
export:
	@echo "→ wiping static-site/"
	rm -rf static-site

	@echo "→ exporting via wget…"
	wget \
	  --mirror \
	  --adjust-extension \
	  --convert-links \
	  --page-requisites \
	  --no-parent \
	  --no-host-directories \
	  --cut-dirs=1 \
	  --reject "xmlrpc.php*" \
	  --directory-prefix=static-site \
	  http://localhost:8080/

	@echo "→ staging all changes"
	git add -A

	@echo "→ committing"
	git commit -m "chore: update static export" || echo "↻ nothing to commit"

	@echo "→ ensuring GitHub repo exists & pushing"
	gh repo create $(GITHUB_USER)/$(REPO_NAME) \
	  --public \
	  --source=. \
	  --remote=origin \
	  --push \
	  --disable-wiki \
	  --disable-issues \
	  -y || true

	@echo "→ pushing branch '$(BRANCH)'"
	git push -u origin $(BRANCH)


# ─── One-step deploy (optional) ───────────────────────────────────────────────
.PHONY: deploy
deploy: export
