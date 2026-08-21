DIR_COMPOSE=./srcs/docker-compose.yml
VOLUME__WP_DB=wp_database
VOLUME_WP_FILES=wp_files
PATH_HOST=~/data

all: help

help:
	@echo "Options available"
	@echo "add: creates folders for volumes"
	@echo "build: creates images"
	@echo "up: starts the containers in background"
	@echo "down: stops and deletes containers"
	@echo "rebuild: builds from scratch images"
	@echo "logs: shows the log of the api - if adding service='...' can get logs for specific service"
	@echo "clean: deletes created by add rule"
	@echo "fclean: deletes all images and volumes not used by any container"

add:
	mkdir -p ${PATH_HOST}/$(VOLUME__WP_DB)
	mkdir -p ${PATH_HOST}/$(VOLUME_WP_FILES)
build:
	docker compose -f ${DIR_COMPOSE} build
up: add
	docker compose -f ${DIR_COMPOSE} up -d
down: clean
	docker compose -f ${DIR_COMPOSE} down -v
rebuild:
	docker compose -f ${DIR_COMPOSE} build --no-cache
logs:
	@if [ -z "$(service)" ]; then \
		docker compose -f ${DIR_COMPOSE} logs; \
	else \
		docker compose -f ${DIR_COMPOSE} logs $(service); \
	fi
clean:
	rm -rf ${PATH_HOST}/$(VOLUME__WP_DB)
	rm -rf ${PATH_HOST}/$(VOLUME_WP_FILES)
fclean:
	docker image prune -a -f
	docker volume prune -a -f