# ─── User settings ───────────────────────────────────────────────────────────
GITHUB_USER ?= windikite

RAW_NAME    := $(shell basename "$(shell git rev-parse --show-toplevel 2>/dev/null)")
REPO_NAME   := $(shell echo $(RAW_NAME) \
                    | tr ' ' '-' \
                    | tr '[:upper:]' '[:lower:]')
BRANCH      := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)

# ─── Export & push ────────────────────────────────────────────────────────────
.PHONY: export
export:
	@echo "→ wiping static-site/"
	@rm -rf static-site

	@echo "→ exporting via wget…"
	@wget \
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
	@git add -A

	@echo "→ committing"
	@git commit -m "chore: update static export" || echo "↻ nothing to commit"

	@echo "→ creating GitHub repo (if needed) & setting remote→HTTPS"
	@gh repo create $(GITHUB_USER)/$(REPO_NAME) \
	  --public \
	  --source=. \
	  --remote=origin \
	  --push \
	  --disable-wiki \
	  --disable-issues \
	  -y || true

	# force origin to HTTPS so pushes never use SSH:
	@echo "→ resetting origin to https://github.com/$(GITHUB_USER)/$(REPO_NAME).git"
	@git remote remove origin 2>/dev/null || true
	@git remote add    origin https://github.com/$(GITHUB_USER)/$(REPO_NAME).git

	@echo "→ pushing branch '$(BRANCH)'"
	@git push -u origin $(BRANCH)

# ─── One-step deploy ──────────────────────────────────────────────────────────
.PHONY: deploy
deploy: export
