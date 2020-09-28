FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN (yes | unminimize) \
    && apt-get update \
    && apt-get upgrade -y
    # https://bugs.launchpad.net/ubuntu/+source/command-not-found/+bug/1872837
    # command-not-found is known to have issues that prevent `apt-get update`, so we explicitly mark it to not be installed
RUN apt-mark hold command-not-found python3-commandnotfound \
    # prevent some cruft from being installed
    && apt-mark hold libreoffice-* thunderbird transmission-* \
    && apt-get install -y supervisor sudo wget curl lsb-release ca-certificates curl apt-transport-https gnupg \
# locale
    && apt-get install -y locales \
    && locale-gen "en_US.UTF-8" \
    && update-locale LANG='en_US.UTF-8' LANGUAGE=en_US
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
# locale

RUN apt-get install -y \
    # tools
    tmux \
    git build-essential ubuntu-standard \
    python2 python2-dev \
    python3 python3-dev \
    ruby ruby-dev ruby-bundler \
    golang \
    vim \
    zsh man-db \
    openjdk-8-jdk openjdk-8-jdk-headless \
    jq \
    # development libs (required by python eggs, ruby gems etc)
    libffi-dev libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses5-dev libncursesw5-dev xz-utils tk-dev liblzma-dev \
# desktop
    ubuntu-mate-desktop xclip \
    && apt-get purge -y command-not-found python3-commandnotfound
# browsers
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - \
    && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && apt-get install -y firefox
# Remote access
RUN apt-get install -y xrdp x11vnc \
    && apt-get install -y tightvncserver \
    && adduser xrdp ssl-cert \
    && sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini \
    && sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini \
    && xrdp-keygen xrdp auto
ADD supervisor/xrdp.conf /etc/supervisor/conf.d/xrdp.conf
# End remote access

RUN \
    # vscode and azure cli
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/packages.microsoft.gpg > /dev/null \
    && echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list \
    && echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/azure-cli $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update \
    && apt-get install -y code azure-cli \
    #idea
    && mkdir -p /opt/idea \
    && wget -qO- https://download.jetbrains.com/idea/ideaIU-2020.2.2.tar.gz | tar -zxf - -C /opt/idea --strip-components 1 \
    && ln -sf /opt/idea/bin/idea.sh /usr/local/bin/idea.sh \
    && ln -sf /opt/idea/bin/idea.sh /usr/local/bin/idea

# docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io \
    && curl -L "https://github.com/docker/compose/releases/download/1.27.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose
ADD supervisor/dockerd.conf /etc/supervisor/conf.d/dockerd.conf

ADD bootstrap.sh /
ADD create-users /
ADD modprobe /usr/local/sbin/
CMD /bootstrap.sh

EXPOSE 3389
