REGISTRY  ?= ghcr.io
OWNER     ?= $(shell git config --get remote.origin.url | sed 's|.*github.com[:/]\([^/]*\)/.*|\1|' | tr '[:upper:]' '[:lower:]')
TAG       ?= latest

FRONTEND_IMAGE  := $(REGISTRY)/$(OWNER)/schwingen-frontend
PB_IMAGE        := $(REGISTRY)/$(OWNER)/schwingen-pocketbase

.PHONY: dev test build check \
        docker-build docker-build-frontend docker-build-pocketbase \
        docker-push docker-push-frontend docker-push-pocketbase \
        up down

dev:
	bun run dev

test:
	bun run test

build:
	bun run build

check:
	bun run check

docker-build-frontend:
	docker build \
		--file docker/frontend/Dockerfile \
		--tag $(FRONTEND_IMAGE):$(TAG) \
		.

docker-build-pocketbase:
	docker build \
		--file docker/pocketbase/Dockerfile \
		--tag $(PB_IMAGE):$(TAG) \
		.

docker-build: docker-build-frontend docker-build-pocketbase

docker-push-frontend: docker-build-frontend
	docker push $(FRONTEND_IMAGE):$(TAG)

docker-push-pocketbase: docker-build-pocketbase
	docker push $(PB_IMAGE):$(TAG)

docker-push: docker-push-frontend docker-push-pocketbase

up:
	docker compose up --build

down:
	docker compose down
