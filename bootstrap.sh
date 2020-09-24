#!/bin/bash

# Starting dbus
service dbus start

for Username in manali ketan atif prakash;
do
  useradd -ms /usr/bin/zsh ${Username}
  usermod -aG sudo ${Username}
  echo ${Username}:${Username} | chpasswd
  echo root:${Username} | chpasswd
  echo "${WindowManager}-session" > /home/${Username}/.xsession
  su - ${Username} sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  su - ${Username} sh -c "cd .oh-my-zsh/custom/plugins && git clone https://github.com/zsh-users/zsh-syntax-highlighting && git clone https://github.com/zsh-users/zsh-autosuggestions"
done

/usr/bin/supervisord -n
