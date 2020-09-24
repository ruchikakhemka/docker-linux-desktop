#!/bin/bash

/create-users

# Starting dbus
service dbus start
exec /usr/bin/supervisord -n
