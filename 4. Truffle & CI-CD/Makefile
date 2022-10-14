DC = docker compose
NETWORK = development

# Get help
help:
	@ echo
	@ echo '  Usage:'
	@ echo ''
	@ echo '    make <target> [flags...]'
	@ echo ''
	@ echo '  Targets:'
	@ echo ''
	@ awk '/^#/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?:/{ print "   ", $$1, comment }' $(MAKEFILE_LIST) | column -t -s ':' | sort
	@ echo ''
	@ echo '  Flags:'
	@ echo ''
	@ awk '/^#/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?\?=/{ print "   ", $$1, $$2, comment }' $(MAKEFILE_LIST) | column -t -s '?=' | sort
	@ echo ''


# Build containers
build:
	$(DC) build

# Run containers
start:
	$(DC) up

# Stop and remove containers
stop:
	$(DC) down

# Compile contracts
compile:
	$(DC) exec truffle truffle compile

# Deploy contracts
migrate:
	$(DC) exec truffle truffle migrate --network $(NETWORK)

# Open truffle console
console:
	$(DC) exec truffle truffle console

# Run tests
test:
	$(DC) exec truffle truffle test

# Install node package with argument PACKAGE
install-package:
	$(DC) exec truffle npm install $(PACKAGE)

.PHONY: build start stop compile migrate console test
