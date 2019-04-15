FROM ubuntu:18.04

# if running as a jenkins slave:
# 1. docker build --tag jenkins/ww-build-env:latest --build-arg mode=jenkins .
# 2. docker run with the following options:
#	-d # daemonize
#	-u root:root # run as root for permission to start sshd in the container
#	-p 2222:22 # map host port 2222 to container port 22 for sshd
#	-v jenkins-data:/home/jenkins # persistent jenkins storage on the host is mapped to $HOME
#	 <image-name>:latest # the name of the image produced by this Dockerfile
#	 /usr/sbin/sshd -D # start sshd
#    A note about the persistent storage: The left-hand argument is specified
#    from the perspective of the host running the docker daemon, i.e., the
#    original owner of /var/run/docker.sock, not the perspective of any
#    intermediate docker container.  For example, if we are trying to share
#    the jenkins home directory between a Jenkins master and a Jenkins slave
#    (this Dockerfile) running on the same host, and we docker-exec into the
#    Jenkins master container, we see that jenkins $HOME is /var/jenkins_home/
#    and that it is full of files and folders.  However, it would be incorrect
#    for us to specify /var/jenkins_home as the left-hand argument to this
#    container here because /var/jenkins_home may not exist on the host, or
#    may be empty.  In other words, the folder /var/jenkins_home in the
#    master container could be mapped from somewhere else on the host.  To find
#    out for sure, we need to docker-inspect the Jenkins master container
#    and look at its Volumes and Mounts.
# 3. add the master's public ssh key to the slave's authorized_keys
#    docker exec -it <slave-container> /bin/bash
#	note: on the current jenkins master, the pubkey is
#		/var/jenkins_home/.ssh/id_rsa.pub
# 	paste the master's jenkins user pubkey into
#		/home/jenkins/.ssh/authorized_keys
#	exit
# 4. add the slave's sshd server key to the master's known_hosts file
#	on the master:
#	su - jenkins
#	ssh -p 2222 <IP of host running jenkins slave>
#		The authenticity of host '[172.17.0.1]:2222 ([172.17.0.1]:2222)' can't be established.
#		ECDSA key fingerprint is SHA256:xqVNaUF5TUniMjSV9PJkhB9gG5N6bI3vBu1Qmn4F5v8.
#		Are you sure you want to continue connecting (yes/no)? yes
#		Warning: Permanently added '[172.17.0.1]:2222' (ECDSA) to the list of known hosts.

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
		pxz \
		rsync \
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

# additional build utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
        u-boot-tools

# if we're building a jenkins agent, we must also install openjdk
# and an ssh server so the master can log in
ARG mode
RUN if [ "$mode" = "jenkins" ]; then \
	apt-get update && apt-get install -y --no-install-recommends \
		gpg-agent \
		openjdk-8-jdk \
		openjdk-8-jre \
		openssh-server; \
	mkdir -p /var/run/sshd; \
	sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; \
fi

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ENV LANG en_US.UTF-8
ENV HOME /home/${user}
RUN groupadd -g ${gid} ${group} \
&& useradd -c "User" -d $HOME -u ${uid} -g ${gid} -m ${user} \
&& adduser ${user} sudo \
&& sed -i 's/%sudo	ALL=(ALL:ALL) ALL/%sudo	ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers

USER ${user}

# accept the host key for github
RUN mkdir ${HOME}/.ssh \
&& chmod 700 ${HOME}/.ssh \
&& ssh-keyscan -H github.com > ${HOME}/.ssh/known_hosts

WORKDIR /home/${user}
CMD /bin/bash
