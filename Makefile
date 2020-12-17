-include dockerfile-commons/test-dockerignore.mk
-include dockerfile-commons/lint-dockerfiles.mk
-include dockerfile-commons/docker-funcs.mk


IMAGE_NAME=semenovp/tiny-elm
VCS_REF=$(shell git rev-parse --short HEAD)

.DEFAULT_GOAL := build


.PHONY: help
help:  ## Prints the help.
	@echo 'Commands:'
	@grep --no-filename -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
	 awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'


define test_image
	$(call goss_docker_image,"$(IMAGE_NAME):$(1)","tests/$(2).yaml")
endef
.PHONY: test
test:  ## Tests the the already built images.
	@$(call test_image,latest,elm)
	@$(call test_image,a-latest,elm-analyse)
	@$(call test_image,t-latest,elm-test)
	@$(call test_image,r-latest,elm-review)


define build_image
	$(call build_docker_image,"$(IMAGE_NAME):$(1)","vcsref=\"$(VCS_REF)\" elmpackages=\"$(2)\"")
endef
.PHONY: build
build: lint-dockerfiles  ## Builds all the images.
	@$(call build_image,latest,)
	@$(call build_image,t-latest,elm-test)
	@$(call build_image,a-latest,elm-analyse)
	@$(call build_image,r-latest,elm-review)
	@$(call build_image,t-latest,elm-test)
	@$(call build_image,ta-latest,elm-test elm-analyse)
	@$(call build_image,all-latest,elm-test elm-analyse elm-review)


.PHONY: clean
clean:  ## Cleans out the docker images built by 'make build'.
	@(docker rmi $$(docker images -q $(IMAGE_NAME)) 2> /dev/null || true)
	@docker system prune -f
