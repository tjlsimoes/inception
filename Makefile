LOGIN   := tjorge-l
DC      := docker compose -f srcs/docker-compose.yml

all: setup up

setup:
	echo "Setting up hosts file..."
	sudo srcs/tools/setup-hosts.sh

up:
	mkdir -p /home/$(LOGIN)/data/wordpress /home/$(LOGIN)/data/mariadb /home/$(LOGIN)/data/redis /home/$(LOGIN)/data/static_site /home/${LOGIN}/data/portainer
	$(DC) up -d --build

down:
	$(DC) down

re: down up

clean: down
	docker volume rm $(docker volume ls -q) 2>/dev/null || true

fclean: clean
	docker system prune -af --volumes
	echo "To clean up /etc/hosts entries, run: sudo srcs/tools/cleanup-hosts.sh"

reset-data:
    sudo rm -rf /home/$(LOGIN)/data/*

.PHONY: all up down re clean fclean