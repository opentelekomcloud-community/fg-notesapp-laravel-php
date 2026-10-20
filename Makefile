SHELL:=/bin/bash
TARGET_PATH=target
DOCKER_FILE=Dockerfile

IMAGE_NAME=notes-app-laravel-php

IMAGE_TAG := "v-$(shell date +%Y%m%d%H%M%S)"

build: clean

docker_build: 
	docker buildx build \
	  --platform linux/amd64 \
	  --build-arg GIT_COMMIT=$(shell git rev-parse HEAD) \
		--file $(DOCKER_FILE) \
		--tag $(IMAGE_NAME):$(IMAGE_TAG) .

docker_run_local:
	docker container run \
	  --rm \
		--platform linux/amd64 \
		--publish 8000:8000 \
		--user 1003:1003 \
		--name $(IMAGE_NAME) \
		$(IMAGE_NAME):$(IMAGE_TAG)

docker_push: docker_build
  # see: https://docs.otc.t-systems.com/software-repository-container/umn/image_management/obtaining_a_long-term_valid_login_command.html#swr-01-1000
	docker login -u $(OTC_SDK_PROJECTNAME)@$(OTC_SDK_AK) -p $(OTC_SWR_LOGIN_KEY) $(OTC_SWR_ENDPOINT)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(OTC_SWR_ENDPOINT)/$(OTC_SWR_ORGANIZATION)/$(IMAGE_NAME):$(IMAGE_TAG)
	docker push $(OTC_SWR_ENDPOINT)/$(OTC_SWR_ORGANIZATION)/$(IMAGE_NAME):$(IMAGE_TAG)

docker_all: build docker_build docker_push


clean:
	rm -rf $(TARGET_PATH)

all: build docker_build

.PHONY: build run_local docker_build docker_run_local docker_push docker_all clean
