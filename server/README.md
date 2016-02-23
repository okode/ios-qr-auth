iOS QR Auth - Server
====================

Building
--------

    $ docker-compose build

Running
-------

    $ docker-compose up -d

Open browser at http://$(docker-machine ip):3001

Developing
----------

While container is started you can edit and modify source
files and reload changes in the browser without needed for
stopping / restarting docker containers.

Stopping
--------

    $ docker-compose stop

Exposing VM ports
-----------------

    $ brew install netcat
    $ while true; do netcat -L $(docker-machine ip):3001 -p 3001; done
    $ while true; do netcat -L $(docker-machine ip):3002 -p 3002; done

