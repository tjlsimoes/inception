SHELL := /bin/bash
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
include srcs/.env

.PHONY: all prep certs secrets build up down logs hosts

all: prep certs build up

prep:
	@echo "Creating host data directories at /home/$(HOST_LOGIN)/data ..."
	mkdir -p /home/$(HOST_LOGIN)/data/db_data
	mkdir -p /home/$(HOST_LOGIN)/data/wp_files
	mkdir -p /home/$(HOST_LOGIN)/data/secrets
	mkdir -p srcs/nginx/certs
	@echo "Directories created. Please add secret files under /home/$(HOST_LOGIN)/data/secrets/"

certs:
	@echo "Generating self-signed certs for $(DOMAIN) into srcs/nginx/certs (dev only)"
	if [ ! -f srcs/nginx/certs/privkey.pem ]; then \
		openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
		  -subj "/CN=$(DOMAIN)/O=$(DOMAIN)" \
		  -keyout srcs/nginx/certs/privkey.pem \
		  -out srcs/nginx/certs/fullchain.pem; \
		echo "Generated srcs/nginx/certs/fullchain.pem and privkey.pem"; \
	else \
		echo "Certs already exist at srcs/nginx/certs/"; \
	fi

build:
	@echo "Building docker images using docker compose"
	docker compose -f srcs/docker-compose.yml build --no-cache

up:
	@echo "Starting services..."
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

logs:
	docker compose -f srcs/docker-compose.yml logs -f

hosts:
	@echo "Updating /etc/hosts for $(DOMAIN)..."
	@sudo bash -c 'HOSTS_FILE=/etc/hosts; DOMAIN_LINE="127.0.0.1    $(DOMAIN)"; if grep -q "$(DOMAIN)" $$HOSTS_FILE; then sed -i.bak "/$(DOMAIN)/c\\$$DOMAIN_LINE" $$HOSTS_FILE; else echo "$$DOMAIN_LINE" >> $$HOSTS_FILE; fi'
	@echo "/etc/hosts updated (backup created at /etc/hosts.bak if replaced)."
