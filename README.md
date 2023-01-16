# Docker container for OSPRay development

# About ```Dockerfile```
```Dockerfile``` sets dependencies for building OSPRay and OSPRay Studio (tested with OSPRay v2.10.0 and OSPRay Studio v0.11.1).

## Build OSPRay from the Docker container
This sub-section shows steps for building OSPRay from the container.

To set up, run the following commands:
```0
# clone OSPRay (we will build this later from a container)
git clone git@github.com:jungwhonam-tacc/ospray.git

# clone this repo containing the Dockerfile
git clone git@github.com:GregAbram/TACCOspray.git

# build a Docker image (feel free to change the image name and tag)
cd TACCOspray
docker build -t jungwhonam/ospray:0.1 .
```

Let's run interactively run Docker. 
> Replace ```/Users/jnam/Documents/2022/OSPRayIntegration/ospray``` with the folder that contains the cloned OSPRay.

> If you do not have X-Server installed, please see the last section.


```
docker run -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=host.docker.internal:0 -v /Users/jnam/Documents/2022/OSPRayIntegration/ospray:/home/ospray/ --rm -it jungwhonam/ospray:0.1 
```

Build OSPRay from the container.
```
mkdir build-container
cd build-container
cmake ../scripts/superbuild -DCMAKE_BUILD_TYPE=Release -DBUILD_OSPRAY_MODULE_MPI=ON
cmake --build .
```

There are serveral example programs, which are located in ```build-container/install/ospray/bin```.
```
# non-GUI example
./install/ospray/bin/ospTutorial
# GUI example
./install/ospray/bin/ospExamples
# MPI GUI example
mpirun -n 2 ./install/ospray/bin/ospMPIDistribTutorialSpheres
```

## Notes on Windows
***On Windows*** getting the shared directory is a bit more complicated.  You need to use volume mounts (see Docker info).
I think this means that the volume is not visible to the host (?)
Using WSL prompt for host-side commands:

Make a volume in Docker Desktop, e.g., ospLocal.   Then use runM.sh::
```
docker run -d --name osp --mount source=ospLocal,target=/home/ospray/local gregabram/ospray-dev
```

Then you need to chmod a+rX local in the container.  Need root 

From host, open prompt in container as root:

```
docker exec -it -u 0 osp bash
```

Now in the container,
```
mkdir src
git clone https://github.com/ospray/ospray_studio.git
cd ospray_studio
git checkout release-0.10.0


mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$HOME/local ..
make -j 6
make install
```

Building ospray using CMake Superbuild
```
cd ~/local/src
git clone https://github.com/ospray/ospray.git
git checkout release-2.9.x
mkdir build
cd build
cmake --build .
```
_Note: this failes on openvkl the first time; seems better second time through (need to check)_

---

# About ```Dockerfile.ospray```
```Dockerfile.ospray``` downloads an OSPRay release and builds it from the environment set by ```Dockerfile```. Currently, it downloads a pre-release version that our team at TACC is working on. 

To build the specific docker file run the following command:

```
docker build . -t jungwhonam/ospray-multidisplays:0.2 -f Dockerfile.ospray
```

Docker can be used in different ways. 

> If X is not needed, remove the following line: ```-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=host.docker.internal:0```.

> When running an example program without specifying an interactive ```-it``` run, give *absolute* paths to configuration files. This applies for both ```display_settings.json``` and ```tracking_settings.json``` files.

1. Run Docker interactively.
```
docker run \
-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=host.docker.internal:0 \
--rm -it  jungwhonam/ospray-multidisplays:0.2
```

2. Run an example, ospMPIMultiDisplays, without MPI.
```
docker run \
-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=host.docker.internal:0 \
--rm -it  jungwhonam/ospray-multidisplays:0.2 \
/home/ospray/ospray-2.11.0-alpha.1/build/install/ospray/bin/ospMPIMultiDisplays \
/home/ospray/ospray-2.11.0-alpha.1/build/install/ospray/bin/config/display_settings.json \
/home/ospray/ospray-2.11.0-alpha.1/build/install/ospray/bin/config/tracking_settings.json
```

3. Run an example, ospMPIMultiDisplays, with MPI.
```
docker run \
-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=host.docker.internal:0 \
--rm -it  jungwhonam/ospray-multidisplays:0.2 \
mpirun -n 3 /home/ospray/ospray-2.11.0-alpha.1/build/install/ospray/bin/ospMPIMultiDisplays \
/home/ospray/ospray-2.11.0-alpha.1/build/install/ospray/bin/config/display_settings.json \
/home/ospray/ospray-2.11.0-alpha.1/build/install/ospray/bin/config/tracking_settings.json
```

---

# About ```X11```
```X11``` is a remote-display protocol by Linux/Unix machines. In our case, this is used to run GUI programs in a Docker container and show the programs in Windows/Mac (mainly used for dev purposes).

Linux has X11 that comes with by default. But we need to install 3rd party softwares for Mac and Windows.

## Install X-Server on Windows (using VCXsrv)

Follow steps in [this tutorial](https://medium.com/javarevisited/using-wsl-2-with-x-server-linux-on-windows-a372263533c3). 

Or if you already installed WSL2 (type ```wsl``` on CMD to check).

1. Download and install [VCXsrv](https://sourceforge.net/projects/vcxsrv/).
2. Open CMD and type the following line to start the X-Server: ```"C:\Program Files\VcXsrv\vcxsrv.exe" :0 -ac -terminate -lesspointer -multiwindow -clipboard -wgl -dpi auto```

## Install X-Server on Mac (using XQuartz)
Download and install [XQuartz](https://www.xquartz.org/). 

However, you may run into these two errors:

```
xterm: Xt error: Can't open display: host.docker.internal:0
```

If you type ```xterm``` from the container and see this error, change the security settings for XQuartz.
   - Turn off _Authenticate connections_
   - Turn on _Allow connections form network clients_

```
libGL error: No matching fbConfigs or visuals found
libGL error: failed to load driver: swrast
error 65543: GLX: Failed to create context: BadValue (integer parameter out of range for operation)
terminate called after throwing an instance of 'std::runtime_error'
what():  Failed to create GLFW window!
```

When you run an application from the container and see these errors, you need to enable _iglx_ (see [Nicola's post](https://unix.stackexchange.com/questions/429760/opengl-rendering-with-x11-forwarding)).