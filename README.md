# Docker Linux Desktop

Supports Xfce and Mate window manager

## How to run

With docker-compose:

Xfce: `docker-compose up LinuxDesktopXfce`
Mate: `docker-compose up LinuxDesktopMate`

## Username and password

The current default username and password are `someuser` and `someuser`. You can set the `Username` environment variable to change the username, the password will be same as the username.

# TBD

Volume mounting (home dir?) to make sure state is persisted across restarts.
