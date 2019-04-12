# Build environment for Pelion OS Edge firmware

This repo contains a set of instructions (this README) and some scripts for building the Pelion OS Edge firmware image.

The README assumes that the poky repo is cloned in the same directory as this repo.  For example:

    ~/build/
        build-env/
        poky/

If you cloned the poky repo at a different location, or named the repo a different name, you will need to modify the POKY variable in the Makefile or define the POKY in your shell environment.

## Requirements

    docker
    build-essential

## Easy Instructions

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
