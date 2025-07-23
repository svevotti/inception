DIR_COMPOSE=./srcs/docker-compose.yml
VOLUME__WP_DB=wp_database
VOLUME_WP_FILES=wp_files
PATH_HOST=./home/smazzari42
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
clean:
	rm -rf ${PATH_HOST}/$(VOLUME__WP_DB)
	rm -rf ${PATH_HOST}/$(VOLUME_WP_FILES)