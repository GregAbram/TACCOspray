docker run -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=host.docker.internal:0 -v  `pwd`:/home/ospray -di gregabram/mympi

