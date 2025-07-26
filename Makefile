DIR_COMPOSE=./srcs/docker-compose.yml
VOLUME__WP_DB=wp_database
VOLUME_WP_FILES=wp_files
#path host to change in /home/smazzari/data
PATH_HOST=./home/smazzari42
add:
	mkdir -p ${PATH_HOST}/$(VOLUME__WP_DB)
	mkdir -p ${PATH_HOST}/$(VOLUME_WP_FILES)
build:
	docker compose -f ${DIR_COMPOSE} build
up: add
	docker compose -f ${DIR_COMPOSE} up -d
build-up: add
	docker compose -f ${DIR_COMPOSE} up -d --build
down: clean
	docker compose -f ${DIR_COMPOSE} down -v
rebuild:
	docker compose -f ${DIR_COMPOSE} build --no-cache
logs:
	docker compose -f ${DIR_COMPOSE} logs
ps:
	docker compose -f ${DIR_COMPOSE} ps
start:
	docker compose -f ${DIR_COMPOSE} start
stop:
	docker compose -f ${DIR_COMPOSE} stop
restart:
	docker compose -f ${DIR_COMPOSE} restart
clean:
	rm -rf ${PATH_HOST}/$(VOLUME__WP_DB)
	rm -rf ${PATH_HOST}/$(VOLUME_WP_FILES)