FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        screen \
		sudo \
		emacs-nox \
		ssh \
		git \
		net-tools \
		locales \
		debconf-utils

COPY locales.selections /tmp/
RUN debconf-set-selections < /tmp/locales.selections \
&& locale-gen en_US.UTF-8 \
&& update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

ARG user
ARG group
ARG uid
ARG gid

ENV LANG en_US.UTF-8
ENV HOME /home/${user}
RUN groupadd -g ${gid} ${group} \
&& useradd -c "User" -d $HOME -u ${uid} -g ${gid} -m ${user} \
&& adduser ${user} sudo \
&& sed -i 's/%sudo	ALL=(ALL:ALL) ALL/%sudo	ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers

USER ${user}
WORKDIR /home/${user}
CMD /bin/bash
