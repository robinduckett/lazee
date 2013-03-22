![The Lazee Sloth](http://i.imgur.com/DRmfc7t.png)

# Lazee

A media encoding / server for sirs.

## Installation instructions

Make sure Transmission / transmission-daemon is running.

As root:

    useradd node

    touch /var/log/lazee-encoder.log
    touch /var/log/lazee-server.log

    chown node:node /var/log/lazee*
    chmod u+rw /var/log/lazee*

    git clone git@bitbucket.org:haxd/lazee.git /home/node/lazee

    pushd /home/node/lazee

    pushd server
    npm install
    popd

    pushd encoder
    npm install
    popd

    chown -R node:node /home/node/lazee
    chmod u+x server/bin/server
    chmod u+x encoder/bin/encoder

    popd

## Service installation

### Upstart script

Copy the files in `/home/node/lazee/config/upstart` to `/etc/init/`

You should now be able to run the following commands

    start lazee-encoder
    start lazee-server

    stop lazee-encoder
    stop lazee-server

    restart lazee-encoder
    restart lazee-server

To start, stop and restart the service respectively. You MUST run the encoder service BEFORE the server.

### Monit

#### Install monit

    sudo apt-get install monit

Copy the files in `/home/node/lazee/config/monit` to `/etc/monit/conf.d/`

Modify the monit configuration file (`/etc/monit/monitrc`) and add the following to the end of the file,
before the line "include /etc/monit/conf.d/*"

    set httpd port 2812 and
       use address 0.0.0.0  # only accept connection from localhost
       allow localhost        # allow localhost to connect to the server and
       allow 0.0.0.0/0.0.0.0        # allow localhost to connect to the server and
       allow admin:monit      # require user 'admin' with password 'monit'
       allow @monit           # allow users of group 'monit' to connect (rw)
       allow @users readonly  # allow users of group 'users' to connect readonly

#### Start monit

    monit

#### Monit web service

Visit the web service to check if it's running properly on [http://haxd.net:2812/](http://haxd.net:2812/)

### Upgrading

    pushd /home/node/lazee

    git pull origin master

    rm -rf server/node_modules/*
    rm -rf encoder/node_modules/*

    pushd server
    npm install
    popd

    pushd encoder
    npm install
    popd

    chown -R node:node /home/node/lazee
    chmod u+x server/bin/server
    chmod u+x encoder/bin/encoder

    popd

    restart lazee-encoder
    restart lazee-server