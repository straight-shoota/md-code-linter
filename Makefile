-include Makefile.local # for optional local options

SHARDS := shards	 # The shards command to use
CRYSTAL := crystal # The crystal command to use

# == For applications
APP_NAME := md-code-linter		# The name of the binary to build

.PHONY: build
build: ## Build the application binary
build: bin/$(APP_NAME)

.PHONY: test
test: ## Run test suite
test: shard.lock
	$(CRYSTAL) spec

.PHONY: format
format: ## Apply source code formatting
format: src/** spec/**
	$(CRYSTAL) tool format src spec

docs: ## Generate API docs
docs: src/**
	$(CRYSTAL) docs

bin/$(APP_NAME): src/** shard.lock
	$(SHARDS) build $(APP_NAME)

shard.lock: shard.yml
	$(SHARDS) update

.PHONY: clean
clean:
	rm -f bin/$(APP_NAME)

.PHONY: help
help: ## Show this help
	@echo
	@printf '\033[34mtargets:\033[0m\n'
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "	\033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34moptional variables:\033[0m\n'
	@grep -hE '^[a-zA-Z_-]+ \?=.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = " \\?=.*?## "}; {printf "	\033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34mrecipes:\033[0m\n'
	@grep -hE '^##.*$$' $(MAKEFILE_LIST) |\
		awk 'BEGIN {FS = "## "}; /^## [a-zA-Z_-]/ {printf "	\033[36m%s\033[0m\n", $$2}; /^##	/ {printf "	%s\n", $$2}'
