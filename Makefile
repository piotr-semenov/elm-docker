IMAGE_NAME=semenovp/tiny-elm
VCS_REF=$(shell git rev-parse --short HEAD)

.DEFAULT_GOAL := build


.PHONY: help
help:  ## Prints the help.
	@echo 'Commands:'
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'


.PHONY: lint
lint: Dockerfile  ## Lints the Dockerfile.
	@docker run \
		--rm \
		-v $(PWD)/dockerfile-commons/.hadolint.yaml:/tmp/.hadolint.yaml:ro \
		-i hadolint/hadolint /bin/hadolint -f tty -c /tmp/.hadolint.yaml -< Dockerfile


define test_docker_image
	@GOSS_FILES_PATH=$(PWD)/tests\
	GOSS_FILE=$(1).yaml\
	GOSS_FILES_STRATEGY=cp\
	$(shell which dgoss) run --entrypoint=/bin/sh \
		                     -it $(IMAGE_NAME):$(2)
endef
.PHONY: test
test:  ## Tests the the already built images.
	$(call test_docker_image,elm,latest)
	$(call test_docker_image,elm-test,t-latest)
	$(call test_docker_image,elm-analyse,a-latest)
	$(call test_docker_image,elm-review,r-latest)


define build_docker_image
	@docker build \
		--build-arg vcsref="$(VCS_REF)" \
		--build-arg elmpackages="$(1)" \
		-t $(IMAGE_NAME):$(2) . \
		--no-cache
endef
.PHONY: build
build: lint  ## Builds all the images.
	$(call build_docker_image,,latest)
	$(call build_docker_image,elm-test,t-latest)
	$(call build_docker_image,elm-analyse,a-latest)
	$(call build_docker_image,elm-review,r-latest)
	$(call build_docker_image,elm-test elm-analyse,ta-latest)
	$(call build_docker_image,elm-test elm-analyse elm-review,all-latest)


.PHONY: clean
clean:  ## Cleans out the docker images built by 'make build'.
	@(docker rmi $$(docker images -q $(IMAGE_NAME)) 2> /dev/null || true)
	@docker system prune -f
