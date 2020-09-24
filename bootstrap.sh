#!/bin/bash

/create-users.sh

# Starting dbus
service dbus start
/usr/bin/supervisord -n
