DC = docker compose
DCE = $(DC) exec
IMAGE = hardhat-typescript
PACKAGE = --help

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
	$(DC) up -d

# Stop and remove containers
stop:
	$(DC) down

# Create node_modules
yarn-install:
	$(DCE) $(IMAGE) yarn install

# Install node package with argument PACKAGE
install-package:
	$(DCE) $(IMAGE) yarn add $(PACKAGE)

# Install node package with argument PACKAGE
install-dev-package:
	$(DCE) $(IMAGE) yarn add --dev $(PACKAGE)

# Compil contracts
compile:
	$(DCE) $(IMAGE) yarn hardhat compile

# Test contracts
test:
	$(DCE) $(IMAGE) yarn hardhat test

# Test contracts with verbose
test-verbose:
	$(DCE) $(IMAGE) yarn hardhat test --verbose

# Get tests coverage
coverage:
	$(DCE) $(IMAGE) yarn hardhat coverage $(OPTIONS)

# Deploy contracts
deploy:
	$(DCE) $(IMAGE) yarn hardhat run $(SCRIPT)

# Run Hardhat network
node:
	$(DCE) $(IMAGE) yarn hardhat node

# Execute command COMMAND inside container
exec:
	$(DCE) $(IMAGE) $(COMMAND)

.PHONY: help build start stop nextjs-dev install-package