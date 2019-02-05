FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
		screen \
		sudo \
		emacs-nox \
		ssh \
		git \
		vim \
		curl \
		net-tools \
		locales \
		debconf-utils \
		lsb-release \
		lockfile-progs \
		file

# install dependencies from Travis
RUN apt-get update && apt-get install -y --no-install-recommends \
		build-essential \
		chrpath \
		cpio \
		diffstat \
		debianutils \
		gawk \
		g++-multilib \
		gcc-multilib \
		git \
		git-core \
		libcap-dev \
		libcrypto++-dev \
		libncursesw5-dev \
		libssl-dev \
		libsdl1.2-dev \
		python \
		python3 \
		python3-pip \
		python3-pexpect \
		python-pip \
		python-virtualenv \
		socat \
		texinfo \
		unzip \
		wget \
		xterm \
		zlib1g-dev \
		cron \
		lockfile-progs \
		software-properties-common

COPY ./locales.selections /tmp/
RUN debconf-set-selections < /tmp/locales.selections \
&& locale-gen en_US.UTF-8 \
&& update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

COPY ./dash.selections /tmp/
RUN debconf-set-selections /tmp/dash.selections \
&& dpkg-reconfigure -fnoninteractive dash

# install i386 deps for the nodejs build

RUN dpkg --add-architecture i386 \
&& apt-get update && apt-get install -y --no-install-recommends \
		g++-multilib \
		libssl-dev:i386 \
		libcrypto++-dev:i386 \
		zlib1g-dev:i386

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
