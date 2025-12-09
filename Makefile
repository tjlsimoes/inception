LOGIN   := tjorge-l
DC      := docker compose -f srcs/docker-compose.yml

all: up

up:
	mkdir -p /home/$(LOGIN)/data/wordpress /home/$(LOGIN)/data/mariadb
	$(DC) up -d --build

down:
	$(DC) down

re: down up

clean: down
	docker volume rm $(docker volume ls -q) 2>/dev/null || true

fclean: clean
	docker system prune -af --volumes

.PHONY: all up down re clean fclean