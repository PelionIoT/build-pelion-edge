# Build environment for Wigwag gateway firmware

## Build the docker image

    docker build -t wigwag-build-env_${USER} --build-arg user=${USER} --build-arg group=${USER} --build-arg uid=$(id -u) --build-arg gid=$(id -g) .


## Run the docker image

    docker run -it -v $HOME:$HOME --name wigwag-build-env_${USER} wigwag-build-env_${USER}

You might also want to run that inside of screen to be able to detach and
reattach.
