DOCKERFILE:=Dockerfile
POKY?=$(abspath ../poky)
MAKEFILE:=$(realpath $(lastword $(MAKEFILE_LIST)))
IMAGE_RECIPE:=console-image

define docker_run
	docker run \
		-it \
		-v ${POKY}:${HOME}/poky \
		-v ${HOME}/.ssh:${HOME}/.ssh \
		-v ${MAKEFILE}:${HOME}/Makefile \
		-e EDITOR=vim \
		-e POKY=${HOME}/poky \
		-e TEMPLATECONF=${HOME}/poky/meta-gateway-ww/conf \
		--rm \
		${USER}/ww-build-env:latest \
		$(1)
endef

.PHONY: all
all: Makefile .docker-image
	$(call docker_run, make bb/${IMAGE_RECIPE})

.PHONY: bash
bash:
	$(call docker_run, /bin/bash)

.docker-image: ${DOCKERFILE}
	docker build \
		--tag ${USER}/ww-build-env:$(shell git describe --dirty --always --tags) \
		--tag ${USER}/ww-build-env:latest \
		--build-arg user=${USER} \
		--build-arg group=${USER} \
		--build-arg uid=$$(id -u) \
		--build-arg gid=$$(id -g) \
		--file ${DOCKERFILE} .
	touch $@

bitbake-%:
	$(call docker_run, make bb/$*)

.PHONY: clean
clean: bitbake-clean
	rm .docker-image

##
## The "bb" recipes are meant to be executed from within a Docker container
##
.PHONY:bb/%
bb/%:
	source ${POKY}/oe-init-build-env ${POKY}/build; \
	bitbake $*

.PHONY: bb/clean
bb/clean:
	source ${POKY}/oe-init-build-env ${POKY}/build; \
	bitbake -c clean ${IMAGE_RECIPE}
