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

    $ brew install nmap
    $ ncat -4 -kl -p 3001 --sh-exec "ncat 192.168.99.100 3001"
    $ ncat -4 -kl -p 3002 --sh-exec "ncat 192.168.99.100 3002"

