.PHONY: bootstrap build up down verify doctor update help

# Default target: show help
help:
	@echo "AI Platform Development Commands:"
	@echo "  make bootstrap   - Run bootstrap script to set up local directories and environment"
	@echo "  make build       - Build platform container images"
	@echo "  make up          - Start the platform services in detached mode"
	@echo "  make down        - Stop the platform services and clean up containers"
	@echo "  make verify      - Check status and health of the running services"
	@echo "  make doctor      - Run the diagnostic doctor command to verify environment health"
	@echo "  make update      - Fetch latest platform changes, rebuild, and restart"

bootstrap:
	@bash scripts/bootstrap.sh

build:
	@bash scripts/build.sh

up:
	@bash scripts/up.sh

down:
	@bash scripts/down.sh

verify:
	@bash scripts/verify.sh

doctor:
	@bash scripts/doctor.sh

update:
	@bash scripts/update.sh
