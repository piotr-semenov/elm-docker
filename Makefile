IMAGE_NAME=semenovp/tiny-elm
VCS_REF=`git rev-parse --short HEAD`

.DEFAULT_GOAL := build


lint: Dockerfile
	@docker run \
		--rm \
		-v $(PWD)/.hadolint.yaml:/tmp/.hadolint.yaml:ro \
		-i hadolint/hadolint /bin/hadolint -c /tmp/.hadolint.yaml -< Dockerfile
