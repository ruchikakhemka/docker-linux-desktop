#!/bin/bash

/create-users

# Starting dbus
service dbus start
/usr/bin/supervisord -n
