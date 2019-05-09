# Build environment for Pelion OS Edge firmware

This repo contains a set of instructions (this README) and some scripts for building the Pelion OS Edge firmware image.
When used in conjuction with the [Repo Manifest](https://github.com/armpelionedge/manifest-pelion-os-edge) repository, it automates the complete [Yocto build instructions](https://github.com/armpelionedge/meta-pelion-os-edge/blob/master/BUILD.md).

The README assumes that the poky repo is cloned in the same directory as this repo.  For example:

    ~/build/
        build-env/
        poky/

If you cloned the poky repo at a different location, or named the repo a different name, you will need to modify the POKY variable in the Makefile or define the POKY in your shell environment.

## Requirements

    docker
    build-essential

   [Docker install instructions](https://docs.docker.com/install/linux/docker-ce/ubuntu/)

## Easy Instructions

### Credentials
   Three sets of credentials are needed for inclusion in the firware image. If they are present in this directory, the Makefile will copy them to the appropriate location for the yocto build.

#### Pelion Development Credentials

   Pelion Cloud development credentials are needed for Pelion Edge.  Provision your build with a Pelion Cloud developer certificate if you are building for [Pelion Cloud developer mode](https://cloud.mbed.com/docs/current/connecting/provisioning-development-devices.html).  Copy your Pelion Cloud credentials file to this directory.

#### Upgrade CA Certificate
   Authenticated upgrade requires inclusion of a cerificate authority certificate to be included in the initialization image.   This CA is used to issue the certificates included with an authenticated upgrade.  After obtaining your CA certificate, copy to the local file ./upgradeCA.cert.

#### Firmware Update Manifest Credentials

   If you enabled support for Pelion firmware updates in mbed-edge-core, copy your manifest certificate update_default_resources.c into `recipes-wigwag/mbed-edge-core/files/`.  Run manifest-tool to generate the certificate.  See the documentation on [getting the update resources](https://github.com/ARMmbed/mbed-edge/blob/master/README.md#getting-the-update-resources).

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

    docker build -t pelion-build-env_${USER} --build-arg user=${USER} --build-arg group=${USER} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .

### Run the docker image

    docker run -it -v $HOME/workspace:$HOME/workspace -v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK -e EDITOR=vim --name pelion-build-env_${USER} pelion-build-env_${USER}

You might also want to run that inside of screen to be able to detach and
reattach.

### Setup Build Environment

These instructions should be run from within the Docker container started in the previous step.

    source ../poky/oe-init-build-env ../poky/build

### Manual build with bitbake

    bitbake console-image

## Flashing 
Instructions for flashing the image to an SD card can be found [here](https://github.com/armpelionedge/meta-pelion-edge/blob/master/FLASH.md).
