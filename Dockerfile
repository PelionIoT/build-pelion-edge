FROM ubuntu:14.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        screen

ARG user
ARG group
ARG uid
ARG gid

ENV HOME /home/${user}
RUN groupadd -g ${gid} ${group} \
&& useradd -c "User" -d $HOME -u ${uid} -g ${gid} -m ${user}

USER ${user}
WORKDIR /home/${user}
CMD /bin/bash
