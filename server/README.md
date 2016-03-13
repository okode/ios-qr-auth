iOS QR Auth - Server
====================

Building
--------

    $ docker-compose build

Running
-------

    $ docker-compose up -d

Open browser at http://$(docker-machine ip):8080

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

Replace 8080 with your desired exposed port:

    $ brew install nmap
    $ ncat -4 -kl -p 8080 --sh-exec "ncat $(docker-machine ip) 80"

