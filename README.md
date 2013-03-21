![The Lazee Sloth](http://i.imgur.com/DRmfc7t.png)

# Lazee

A media encoding / server for sirs.

## Installation instructions

Make sure Transmission / transmission-daemon is running.

    useradd node

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

Create a file called `lazee.conf` in `/etc/init/` as the following:

    # /etc/init/lazee.conf
    description "Lazee Service"
    author "Robin Duckett"

    start on (local-filesystems and net-device-up IFACE=eth0)
    stop on shutdown

    setuid node
    setgid node

    script
        cd /home/lazee

        exec encoder/bin/encoder 2>&1 >> /var/log/lazee-encoder.log
        exec server/bin/server 2>&1 >> /var/log/lazee-server.log
    end script

You should now be able to run the commands `start lazee`, `stop lazee` and `restart lazee` to
start, stop and restart the lazee service.

### Monit

#### Install monit

    sudo apt-get install monit

Create or modify the file `/etc/monit/conf.d/lazee`

    # /etc/monit/conf.d/lazee
    check host lazee with address 127.0.0.1
        start program = "/sbin/start lazee"
        stop program = "/sbin/stop lazee"
        if failed port 4999 protocol HTTP
            request /ping
            with timeout 5 seconds
            then restart

Modify the monit conifguration file and add the following to the end of the file,
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