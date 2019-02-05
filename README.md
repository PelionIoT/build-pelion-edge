# Build environment for Wigwag gateway firmware

These instructions assume that this repo is cloned at ~/workspace/wigwag-build-env.  If you cloned the repo at a different location, you will need to make appropriate changes to the commands below.


## Build the docker image

    docker build -t wigwag-build-env_${USER} --build-arg user=${USER} --build-arg group=${USER} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .


## Run the docker image

    docker run -it -v $HOME/workspace:$HOME/workspace -v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK -e EDITOR=vim --name wigwag-build-env_${USER} wigwag-build-env_${USER}

You might also want to run that inside of screen to be able to detach and
reattach.

## Setup Build Environment
These instructions should be run from within the Docker container started in the previous step.

    ssh -T git@github.com
    mkdir build
    cd build
    bash <(curl -fsSLk https://code.wigwag.com/tools/sc/wwysetup.sh)
    > Github Repository path: /home/<user>/workspace/wigwag-build-env/build
    > enter
    ... change yoctoRoot to ${HOME}/workspace/wigwag-build-env/build/Tyocto/
    ... change assembleRoot to ${HOME}/workspace/wigwag-build-env/build/assemble
    ... change distrobutionRoot to ${HOME}/workspace/wigwag-build-env/build/distro
    ... save,quit
    cd Tyocto/thud/poky
    # add "export SSH_AUTH_SOCK" on its own line somewhere near the top of recipes that use oe_runnpm
        # recipes that use oe_runnpm in the do_compile() function need to be modified to allow usage of your sshagent because some of the dependencies listed in package.json are from private repos.
        # Modify the following recipes found in Tyocto/thud/METAS/meta-wigwag/recipes-wigwag:
        1. mbed-devicejs-bridge/mbed-devicejs-bridge_0.0.1.bb
        1. devicejs/devicejs_0.0.12.bb 
        1. node-hotplug/node-hotplug_1.0.bb 
        1. wwrelay-utils/wwrelay-utils_1.0.1.bb 
    echo “1.1.1” > /tmp/BUILDMMU.txt
    source oe-init-build-env

## Auto build with mainBuilder
    ~/workspace/wigwag-build-env/build/wwbuilds/buildmachine/mainBuilder.sh ~/workspace/wigwag-build-env/build/wwbuilds/buildmachine/configs/thud/mainBuilder.cfg ~/workspace/wigwag-build-env/build/wwbuilds/buildmachine/configs/thud/A20-WigWag-dev.cfg

## Manual build with bitbake
    bitbake wwrelay-ng-wpackage
    # TBD assembly steps

## Troubleshooting

1.  Any time the docker container is rebuilt, you must run "ssh -T git@github.com" and accept the github server's pubkey before running bitbake again.
