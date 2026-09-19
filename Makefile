DIR_COMPOSE=./srcs/docker-compose.yml

all: build up

up:
	docker compose -f ${DIR_COMPOSE} up -d
build:
	docker compose -f ${DIR_COMPOSE} build
down:
	docker compose -f ${DIR_COMPOSE} down
rebuild:
	docker compose -f ${DIR_COMPOSE} build --no-cache
help:
	@echo "Options available"
	@echo "build: creates images"
	@echo "up: starts the containers in background"
	@echo "down: stops and deletes containers"
	@echo "rebuild: builds from scratch images"
	@echo "logs + service: shows the log of the api - if adding service='...' can get logs for specific service"
	@echo "fclean: deletes all images and volumes not used by any container"
logs:
	@if [ -z "$(service)" ]; then \
		docker compose -f ${DIR_COMPOSE} logs; \
	else \
		docker compose -f ${DIR_COMPOSE} logs $(service); \
	fi
fclean:
	docker image prune -a -f
	docker volume prune -a -f
