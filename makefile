# ─── Configuration ─────────────────────────────────────────
GITHUB_USER ?= windikite
REPO_NAME   := $(notdir $(CURDIR))
BRANCH      := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)
WP_URL      := http://localhost:8080

# ─── Export ────────────────────────────────────────────────
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
	  $(WP_URL)

# ─── Deploy ────────────────────────────────────────────────
# 1. stage & commit everything you’ve changed locally (WP code, Makefile, etc.)
# 2. ensure GitHub repo exists (over HTTPS)
# 3. push your current branch up
.PHONY: deploy
deploy:
	@echo "→ staging all changes"
	git add -A
	@echo "→ committing"
	git commit -m "chore: deploy on $$(date +'%Y-%m-%d %H:%M:%S')" || echo "↻ nothing to commit"
	@echo "→ creating GitHub repo if needed"
	gh repo create $(GITHUB_USER)/$(REPO_NAME) \
	  --public \
	  --source=. \
	  --remote=origin \
	  --disable-wiki \
	  --disable-issues \
	  --confirm || true
	@echo "→ forcing remote to HTTPS"
	git remote set-url origin https://github.com/$(GITHUB_USER)/$(REPO_NAME).git
	@echo "→ pushing branch '$(BRANCH)' to origin"
	git push -u origin $(BRANCH)
