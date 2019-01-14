FROM ubuntu:14.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        screen

ARG user=ryanow01
ARG group=ryanow01
ARG uid=21809
ARG gid=21809

ENV HOME /home/${user}
RUN groupadd -g ${gid} ${group} \
&& useradd -c "User" -d $HOME -u ${uid} -g ${gid} -m ${user}
