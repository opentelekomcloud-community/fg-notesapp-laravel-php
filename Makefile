SHELL:=/bin/bash

# To use artisan serve as server:
# DOCKER_FILE=Dockerfile

# To use nginx as server:
DOCKER_FILE=docker_nginx/Dockerfile_nginx

IMAGE_NAME=notes-app-laravel-php

IMAGE_TAG := "v-$(shell date +%Y%m%d%H%M%S)-n"

# Local dev DB settings for docker_run_local (override via environment or command line)
# Dev default: SQLite file inside the container (ephemeral; migrations run on start)
# DB_CONNECTION ?= sqlite
# DB_DATABASE ?= /app/database/database.sqlite
DB_HOST ?= 127.0.0.1
DB_PORT ?= 5432
DB_DATABASE ?= notes
DB_USERNAME ?= postgres
DB_PASSWORD ?=
APP_KEY ?=

# Build the app locally: PHP dependencies + frontend assets
# (not needed for docker_build - the image builds its own copies in separate stages)
build:
	composer install --no-interaction
	npm install
	npm run build

docker_build: 
	docker buildx build \
	  --platform linux/amd64 \
	  --build-arg GIT_COMMIT=$(shell git rev-parse HEAD) \
		--file $(DOCKER_FILE) \
		--tag $(IMAGE_NAME):$(IMAGE_TAG) .

docker_run_local: docker_build
	docker container run \
	  --rm \
		--platform linux/amd64 \
		--publish 8000:8000 \
		--user 1003:1003 \
		--name $(IMAGE_NAME) \
		--env DB_CONNECTION=$(DB_CONNECTION) \
		--env DB_HOST=$(DB_HOST) \
		--env DB_PORT=$(DB_PORT) \
		--env DB_DATABASE=$(DB_DATABASE) \
		--env DB_USERNAME=$(DB_USERNAME) \
		--env DB_PASSWORD=$(DB_PASSWORD) \
		--env APP_KEY=$(APP_KEY) \
		$(IMAGE_NAME):$(IMAGE_TAG)

docker_push: docker_build
  # see: https://docs.otc.t-systems.com/software-repository-container/umn/image_management/obtaining_a_long-term_valid_login_command.html#swr-01-1000
	# @ keeps the recipe (with credentials) out of make's output
	@docker login -u $(OTC_SDK_PROJECTNAME)@$(OTC_SDK_AK) -p $(OTC_SWR_LOGIN_KEY) $(OTC_SWR_ENDPOINT)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(OTC_SWR_ENDPOINT)/$(OTC_SWR_ORGANIZATION)/$(IMAGE_NAME):$(IMAGE_TAG)
	docker push $(OTC_SWR_ENDPOINT)/$(OTC_SWR_ORGANIZATION)/$(IMAGE_NAME):$(IMAGE_TAG)

docker_all: docker_build docker_push

# Remove build artifacts and caches (regenerable via 'make build')
# Keeps .env, source code, and database/database.sqlite (local dev data)
clean:
	rm -rf vendor node_modules public/build public/hot \
		bootstrap/cache/*.php storage/logs/* \
		storage/framework/cache/data/* storage/framework/sessions/* \
		storage/framework/views/* .phpunit.result.cache

all: build docker_build

.PHONY: build clean docker_build docker_run_local docker_push docker_all all
