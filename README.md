# Build environment for Pelion gateway firmware

This repo contains a set of instructions (this README) and some scripts for building the Pelion gateway firmware image.
When used in conjuction with the [Repo Manifest](https://github.com/ARMmbed/manifest-gateway-ww) repository, it automates the complete [Yocto build instructions](https://github.com/ARMmbed/meta-gateway-ww/blob/master/BUILD.md).

The README assumes that the poky repo is cloned in the same directory as this repo.  For example:

    ~/build/
        wigwag-build-env/
        poky/

If you cloned the poky repo at a different location, or named the repo a different name, you will need to modify the POKY variable in the Makefile or define the POKY in your shell environment.

## Requirements

    docker
    build-essential

   [Docker install instructions](https://docs.docker.com/install/linux/docker-ce/ubuntu/)

## Easy Instructions

### Credentials
   Two sets of credentials are needed for inclusion in the firware image. If they are present in this directory, the Makefile will copy them to the appropriate location for the yocto build.

#### Pelion Development Credentials

   Pelion Cloud development credentials are needed for Pelion Edge.  Provision your build with a Pelion Cloud developer certificate if you are building for [Pelion Cloud developer mode](https://cloud.mbed.com/docs/current/connecting/provisioning-development-devices.html).  Copy your Pelion Cloud credentials file to this directory.

#### Upgrade CA Certificate
   Authenticated upgrade requires inclusion of a cerificate authority certificate to be included in the initialization image.   This CA is used to issue the certificates included with an authenticated upgrade.  After obtaining your CA certificate, copy to the local file ./upgradeCA.cert.

### Full builds

    make

### Start an interactive Docker container with a bash shell

    make bash

### Build a single package

    make bitbake-<packagename>

### Clean the bitbake environment

    make bitbake-clean

## Harder Instructions

Create a docker container using Dockerfile in this repo and run the container in interactive mode.  Build the firmware image from within Docker.

### Build the docker image

    docker build -t wigwag-build-env_${USER} --build-arg user=${USER} --build-arg group=${USER} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .

### Run the docker image

    docker run -it -v $HOME/workspace:$HOME/workspace -v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK -e EDITOR=vim --name wigwag-build-env_${USER} wigwag-build-env_${USER}

You might also want to run that inside of screen to be able to detach and
reattach.

### Setup Build Environment

These instructions should be run from within the Docker container started in the previous step.

    source ../poky/oe-init-build-env ../poky/build

### Manual build with bitbake

    bitbake console-image

## Flashing 
Instructions for flashing the image to an SD card can be found [here](https://github.com/ARMmbed/meta-gateway-ww/blob/master/FLASH.md).
