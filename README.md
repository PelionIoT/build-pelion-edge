# Build environment for Wigwag gateway firmware

## Build the docker image

    docker build -t wigwag-build-env_${USER} --build-arg user=${USER} --build-arg group=${USER} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .


## Run the docker image

    docker run -it -v $HOME/wigwag_workspace:$HOME/workspace -v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK -e EDITOR=vim --name wigwag-build-env_${USER} wigwag-build-env_${USER}

You might also want to run that inside of screen to be able to detach and
reattach.


## Build Phase 1: Yocto

    $ cd workspace/wigwag-build-env
    $ mkdir build
    $ cd build
    $ bash <(curl -fsSLk https://code.wigwag.com/tools/sc/wwysetup.sh)
    > Github Repository path: /home/niccos01/workspace/wigwag-build-env/build
    > enter
    ... change yoctoRoot to ${HOME}/workspace/wigwag-build-env/build/Tyocto/
    ... change enableBuildAnnouncements to 0
    ... change enableDistroServer to 0
    ... change enableDistroAnnouncements to 0
    ... save,quit
    $ cd Tyocto/thud/poky
    # modify recipe Tyocto/thud/METAS/meta-wigwag/recipes-wigwag/mbed-devicejs-bridge/mbed-devicejs-bridge_0.0.1.bb
        # add "export SSH_AUTH_SOCK"
    # modify any other recipes with oe_runnpm commands in the same way
    $ echo “1.1.1” > /tmp/BUILDMMU.txt
    $ source oe-init-build-env
    $ bitbake wwrelay-ng-wpackage

## Troubleshooting

1.  Any time the docker container is rebuilt, you must run "ssh -T git@github.com" and accept the github server's pubkey before running bitbake again.
