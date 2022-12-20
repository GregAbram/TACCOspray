Docker container for Ospray development


On Windows getting the shared directory is a bit more complicated.  You need to use volume mounts (see Docker info).
I think this means that the volume is not visible to the host (?)
Using WSL prompt for host-side commands:

Make a volume in Docker Desktop - eg ospLocal.   Then use runM.sh::

docker run -d --name osp --mount source=ospLocal,target=/home/ospray/local gregabram/ospray-dev

Then you need to chmod a+rX local in the container.  Need root 

From host, open prompt in container as root:

docker exec -it -u 0 osp bash

Now in the container,

mkdir src
git clone https://github.com/ospray/ospray_studio.git
cd ospray_studio
git checkout release-0.10.0

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$HOME/local ..
make -j 6
make install

Building ospray -- superbuild

cd ~/local/src
git clone https://github.com/ospray/ospray.git
git checkout release-2.9.x
mkdir build
`
