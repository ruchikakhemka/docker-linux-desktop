#!/bin/bash

# Starting dbus
service dbus start

# Add desktop user
echo "Provisioning user ${Username}"
useradd -ms /bin/bash ${Username}
usermod -aG sudo ${Username}
echo ${Username}:${Username} | chpasswd
echo root:${Username} | chpasswd

echo "${WindowManager}-session" > /home/${Username}/.xsession

/usr/bin/supervisord -n
