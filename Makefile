NAME = dw/collections-api
VERSION = $(TRAVIS_BUILD_ID)
ME = $(USER)

all: build up
clean: stop rm

build:
	sudo chown -R $(ME) mysql-datadir
	docker-compose build --no-cache
#	docker build --no-cache -t $(NAME):$(VERSION) .

up:
	echo "start db and load data, please be patient ... a couple of minutes ..."
	docker-compose up -d db
#	docker inspect --format '{{ .NetworkSettings.IPAddress }}:3306' dwcollections_dina-mysql_1 | xargs wget --retry-connrefused --tries=15 -q --waitretry=5
	sleep 5
	./populate_dina_web_db.sh
	./populate_keycloak_db.sh

	echo "bringing up the SSO service"
	docker-compose up -d sso
#	wget --retry-connrefused --tries=15 --waitretry=5 -q "http://localhost:8080/auth"
	sleep 20

	echo "bringing up application server, takes approx 30-50 s"
	docker-compose up -d as
#	wget --retry-connrefused --tries=15 --waitretry=5 -q "http://localhost:8181/test-client"
	sleep 50

	echo "bringing up web server / proxy"
	docker-compose up -d ws-api

stop:
	docker-compose stop

rm:
	docker-compose rm -vf

