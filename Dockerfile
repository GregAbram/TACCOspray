FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get --yes -qq update \
 && apt-get --yes -qq upgrade \
 && apt-get --yes -qq install \
                      bzip2 \
                      cpio \
                      curl \
                      g++-8 \
                      gcc-8 \
                      gfortran \
                      git \
                      gosu \
                      libblas-dev \
                      liblapack-dev \
                      libopenmpi-dev \
                      openmpi-bin \
                      python3-dev \
                      python3-pip \
                      virtualenv \
                      wget \
                      zlib1g-dev \
                      vim       \
                      tzdata \
                      libpulse-dev \
                      xterm \
                      freeglut3-dev \
                      libnss3 \
                      libxcursor1  \
                      libxcursor-dev  \
                      libxi-dev  \
                      libxkbcommon0 \
                      libxrandr-dev \
                      libxinerama-dev \
                      libasound2 \
                      libgssapi-krb5-2 \
                      libqt5gui5 \
                      htop \
                      libglew-dev \
                      libncurses5-dev \
                      gdb

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 8

RUN apt-get update && apt-get -y install openssl libssl-dev

RUN apt-get --yes -qq clean \
 && rm -rf /var/lib/apt/lists/*

RUN useradd --user-group --system --create-home --no-log-init ospray

RUN wget https://github.com/Kitware/CMake/releases/download/v3.24.3/cmake-3.24.3.tar.gz \
  && tar xzf cmake-3.24.3.tar.gz \
  && cd cmake-3.24.3 \
  && ./bootstrap \
  && make \
  && make install

USER ospray
WORKDIR /home/ospray

CMD [ "/bin/bash" ]
