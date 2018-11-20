IMAGE_NAME=semenovp/tiny-elm
VCS_REF=`git rev-parse --short HEAD`

.DEFAULT_GOAL := build


lint: Dockerfile
	@docker run \
		--rm \
		-v $(PWD)/.hadolint.yaml:/tmp/.hadolint.yaml:ro \
		-i hadolint/hadolint /bin/hadolint -c /tmp/.hadolint.yaml -< Dockerfile


define build_docker_image
	@docker build \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg elmpackages="$(1)" \
		-t $(IMAGE_NAME):$(2) .
endef
build: lint
	$(call build_docker_image,elm,latest)
	$(call build_docker_image,elm elm-test,t-latest)
	$(call build_docker_image,elm elm-analyse,a-latest)
	$(call build_docker_image,elm elm-test elm-analyse,ta-latest)
