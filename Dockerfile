FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y supervisor sudo wget curl lsb-release ca-certificates curl apt-transport-https gnupg

# locale
RUN apt-get install -y locales && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
# locale

ARG WindowManager=openbox
ENV WindowManager=$WindowManager
# Window manager
RUN if [ "$WindowManager" = "mate" ]; then apt-get install -y ubuntu-mate-desktop; fi
RUN if [ "$WindowManager" = "xfce4" ]; then apt-get install -y xubuntu-desktop dbus-x11; fi
# Window manager

RUN sh -c 'mkdir -p /opt/idea && wget -qO- https://download.jetbrains.com/idea/ideaIU-2020.2.2.tar.gz | tar -zxf - -C /opt/idea --strip-components 1 && ln -sf /opt/idea/bin/idea.sh /usr/local/bin/idea.sh && ln -sf /opt/idea/bin/idea.sh /usr/local/bin/idea'

# docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    sh -c "echo \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" > /etc/apt/sources.list.d/docker.list" && \
    apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
RUN curl -L "https://github.com/docker/compose/releases/download/1.27.3/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose
# ADD supervisor/dockerd.conf /etc/supervisor/conf.d/dockerd.conf
# docker

# Remote access
RUN apt-get install -y xrdp x11vnc
RUN apt-get install -y tightvncserver
RUN adduser xrdp ssl-cert
RUN sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini && \
    xrdp-keygen xrdp auto
ADD supervisor/xrdp.conf /etc/supervisor/conf.d/xrdp.conf
# End remote access


RUN apt-get install -y zsh man-db

ADD bootstrap.sh /
ADD create-users.sh /
CMD /bootstrap.sh

EXPOSE 3389
