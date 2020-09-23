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


# we install this first, because apparently otherwise something with python messes up the apt-get for microsoft repos
# vscode and azure cli
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor \
        | sudo tee /etc/apt/trusted.gpg.d/packages.microsoft.gpg > /dev/null \
    && echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list \
    && sh -c "echo \"deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/azure-cli $(lsb_release -cs) main\" > /etc/apt/sources.list.d/azure-cli.list" \
    && apt-get update && apt-get install -y code azure-cli
# vscode and azure cli

# Tools
RUN apt-get install -y xterm tmux firefox \
    git build-essential ubuntu-standard \
    python2 python2-dev \
    python3 python3-dev \
    ruby ruby-dev ruby-bundler \
    golang \
    openjdk-8-jdk openjdk-8-jdk-headless
# Tools

# Remote access
RUN apt-get install -y xrdp x11vnc
RUN apt-get install -y tightvncserver
RUN adduser xrdp ssl-cert
RUN sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini && \
    xrdp-keygen xrdp auto
ADD xrdp.conf /etc/supervisor/conf.d/xrdp.conf
# End remote access

ARG WindowManager=openbox
ENV Username=someuser
ENV WindowManager=$WindowManager
# Window manager
RUN if [ "$WindowManager" = "mate" ]; then apt-get install -y ubuntu-mate-desktop; fi
RUN if [ "$WindowManager" = "xfce4" ]; then apt-get install -y xubuntu-desktop dbus-x11; fi
# Window manager

RUN sh -c 'mkdir -p /opt/idea && wget -qO- https://download.jetbrains.com/idea/ideaIU-2020.2.2.tar.gz | tar -zxf - -C /opt/idea --strip-components 1 && ln -sf /opt/idea/bin/idea.sh /usr/local/bin/idea.sh && ln -sf /opt/idea/bin/idea.sh /usr/local/bin/idea'

RUN apt-get install -y zsh

RUN useradd -ms /usr/bin/zsh ${Username} && \
    usermod -aG sudo ${Username} && \
    echo ${Username}:${Username} | chpasswd && \
    echo root:${Username} | chpasswd && \
    echo "${WindowManager}-session" > /home/${Username}/.xsession && \
    su - ${Username} sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    su - ${Username} sh -c "cd .oh-my-zsh/custom/plugins && git clone https://github.com/zsh-users/zsh-syntax-highlighting && git clone https://github.com/zsh-users/zsh-autosuggestions"

ADD bootstrap.sh /
CMD /bootstrap.sh

EXPOSE 3389
