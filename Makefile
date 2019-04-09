DOCKERFILE:=Dockerfile
POKY?=$(abspath ../poky)
MAKEFILE:=$(realpath $(lastword $(MAKEFILE_LIST)))
IMAGE_RECIPE:=console-image

define docker_run
	docker run \
		--privileged=true \
		--device /dev/loop0:/dev/loop0 \
		--device /dev/loop1:/dev/loop1 \
		--device /dev/loop2:/dev/loop2 \
		--device /dev/loop3:/dev/loop3 \
		--device /dev/loop4:/dev/loop4 \
		--device /dev/loop5:/dev/loop5 \
		--device /dev/loop6:/dev/loop6 \
		--device /dev/loop7:/dev/loop7 \
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
all: Makefile .docker-image conf
	cp ./mbed_cloud_dev_credentials.c ${POKY}/meta-gateway-ww/recipes-wigwag/mbed-edge-core/files/
	cp ./upgradeCA.cert ${POKY}/meta-gateway-ww/recipes-core/ww-console-image-initramfs-init/files/
	cp ./update_default_resources.c ${POKY}/meta-gateway-ww/recipes-wigwag/mbed-edge-core/files/
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
	rm -f .docker-image

.PHONY: conf
conf: ${POKY}/build/conf/local.conf ${POKY}/build/conf/bblayers.conf

${POKY}/build/conf/%: ${POKY}/meta-gateway-ww/conf/%.sample
	rm -f ${POKY}/build/conf/$*
	$(call docker_run, make bb/oe-init-build-env)

##
## The "bb" recipes are meant to be executed from within a Docker container
##
.PHONY: bb/%
bb/%:
	source ${POKY}/oe-init-build-env ${POKY}/build; \
	bitbake $*

.PHONY: bb/oe-init-build-env
bb/oe-init-build-env:
	source ${POKY}/oe-init-build-env ${POKY}/build;

.PHONY: bb/clean
bb/clean:
	source ${POKY}/oe-init-build-env ${POKY}/build; \
	bitbake -c clean ${IMAGE_RECIPE}
