FROM gitpod/workspace-full-vnc:latest
LABEL maintainer="ugo.pattacini@iit.it"

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Update apt database
RUN apt update

# Install essentials
RUN apt install -y apt-utils psmisc lsb-release tmux nano wget curl \
                   build-essential git cmake cmake-curses-gui libedit-dev libxml2-dev

# Install graphics
RUN apt install -y xfce4 xfce4-goodies firefox

# Install Java
RUN apt install -y default-jdk

# Install Octave
RUN apt install -y octave epstool transfig

# Install markserv
RUN apt install -y nodejs-dev node-gyp libssl1.0-dev nodejs npm
RUN npm install --global markserv

# Install jupyter
RUN apt install -y python python-dev python-pip ipython
RUN sudo -H pip install jupyter

# Install terminator
RUN apt install -y terminator

# Install yarp dependencies
# gitpod/workspace-full-vnc is based on cosmic and we don't have cosmic release of icub-common yet!
# as fallback we go for bionic
RUN echo "deb http://www.icub.org/ubuntu bionic contrib/science" > /etc/apt/sources.list.d/icub.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 57A5ACB6110576A6
RUN apt update
RUN apt install -y icub-common

# Select branch + build type
ARG BRANCH=devel
ARG BUILD_TYPE=Release

# Build ycm
RUN git clone https://github.com/robotology/ycm.git -b $BRANCH
RUN cd ycm && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install
RUN rm -Rf ycm

# Build robot-testing
RUN git clone https://github.com/robotology/robot-testing.git -b $BRANCH
RUN cd robot-testing && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install
RUN rm -Rf robot-testing

# Build yarp
RUN git clone https://github.com/robotology/yarp.git -b $BRANCH
RUN cd yarp && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DYARP_COMPILE_libYARP_math=ON \
    -DYARP_COMPILE_GUIS=ON \
    -DYARP_COMPILE_DEVICE_PLUGINS=OFF && \
    make install
RUN rm -Rf yarp

# Build icub-main
RUN git clone https://github.com/robotology/icub-main.git -b $BRANCH
RUN cd icub-main && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DENABLE_icubmod_cartesiancontrollerserver=ON \
    -DENABLE_icubmod_cartesiancontrollerclient=ON \
    -DENABLE_icubmod_gazecontrollerclient=ON && \
    make install
RUN rm -Rf icub-main

# Switch to gitpod user
USER gitpod

# Build icub-contrib-common
RUN mkdir /home/gitpod/iCubContrib
RUN cd /home/gitpod && \
    git clone https://github.com/robotology/icub-contrib-common.git && \
    cd icub-contrib-common && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_INSTALL_PREFIX=/home/gitpod/iCubContrib && \
    make install
RUN rm -Rf /home/gitpod/icub-contrib-common
ENV ICUBcontrib_DIR=/home/gitpod/iCubContrib
RUN echo "export PATH=$PATH:/home/gitpod/iCubContrib/bin" >> ~/.bashrc

ARG GITHUB_TOKEN=${token}

# Build audition-projects-helpers
RUN git config --global url."https://$GITHUB_TOKEN:@github.com/".insteadOf "https://github.com/"
RUN git clone https://github.com/dic-iit/audition-projects-helpers.git
RUN git config --global --remove-section url."https://$GITHUB_TOKEN:@github.com/"
RUN cd audition-projects-helpers && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install
RUN rm -Rf audition-projects-helpers

# Switch back to root
USER root

# Run graphics environment
RUN echo "startxfce4 &" >> ~/.bashrc

# Make default contexts discoverable by yarp
ENV YARP_DATA_DIRS=/usr/local/share/yarp:/usr/local/share/iCub:/home/gitpod/iCubContrib/share/ICUBcontrib

# Make dynamic libraries discoverable
ENV LD_LIBRARY_PATH=/usr/local/lib/yarp:/usr/local/lib/robottestingframework

# Manage markserv port
EXPOSE 8080

# Manage jupyter port
EXPOSE 8888

# Manage yarp port
EXPOSE 10000/tcp 10000/udp

# Launch bash from /workspace
WORKDIR /workspace
CMD ["bash"]
