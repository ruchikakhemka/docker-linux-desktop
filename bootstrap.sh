#!/bin/bash

/create-users.sh

# Starting dbus
service dbus start
exec /usr/bin/supervisord -n
