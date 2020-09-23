#!/bin/bash

# Starting dbus
service dbus start

/usr/bin/supervisord -n
