# ─── Configuration ───
GITHUB_USER ?= windikite

# Slugify current folder name (lowercase + hyphens)
REPO_NAME   := $(shell basename "$(CURDIR)" \
	| tr '[:upper:]' '[:lower:]' \
	| sed 's/[^a-z0-9]/-/g')

REMOTE_URL  := https://github.com/$(GITHUB_USER)/$(REPO_NAME).git
BRANCH      := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)
URL         := http://localhost:8080

.PHONY: export deploy

export:
	@echo "→ wiping old export"
	rm -rf static-site
	@echo "→ exporting via wget"
	wget \
		--mirror \
		--adjust-extension \
		--convert-links \
		--page-requisites \
		--no-parent \
		--no-host-directories \
		--cut-dirs=1 \
		--reject-regex '/wp-json.*|xmlrpc\.php.*|\?p=' \
		--directory-prefix=static-site \
		$(URL)/
	@echo "→ renaming versioned assets (strip ?ver=…)"
	find static-site -type f -name '*\?ver=*' -print0 | \
		xargs -0 -I{} bash -c '\
			new="$$(echo "{}" | sed -E "s/\?ver=[^/]+//")"; \
			mv "{}" "$$new" \
		'
	@echo "→ cleaning up HTML"
	find static-site -type f -name '*.html' -exec sed -i \
		-e '/<base href=/d' \
		-e 's#$(URL)##g' \
		-e 's/\?ver=[0-9.]*//g' \
		{} +
	@echo "✅ export complete → static-site/"

deploy:
	@echo "→ staging all changes"
	git add -A
	@echo "→ committing"
	git commit -m "chore: deploy on $$(date +'%Y-%m-%d %H:%M:%S')" || echo "↻ nothing to commit"
	@echo "→ ensuring GitHub repo exists"
	gh repo create $(GITHUB_USER)/$(REPO_NAME) \
		--public \
		--source=. \
		--remote=origin \
		--disable-wiki \
		--disable-issues \
		--confirm || true
	@echo "→ forcing origin to HTTPS"
	git remote set-url origin $(REMOTE_URL)
	@echo "→ pulling remote changes (rebase)"
	git pull --rebase origin $(BRANCH)
	@echo "→ pushing to origin/$(BRANCH)"
	git push -u origin $(BRANCH)
