FROM ubuntu:latest
LABEL maintainer="ugo.pattacini@iit.it"

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Update apt database
RUN apt update

# Install essentials
RUN apt install -y apt-utils sudo psmisc lsb-release tmux nano wget curl \
                   build-essential git gitk cmake cmake-curses-gui libedit-dev libxml2-dev

# Install graphics
RUN apt install -y xfce4 xfce4-goodies xvfb x11vnc firefox

# Install Java
RUN apt install -y default-jdk

# Install Octave
RUN apt install -y octave epstool transfig

# Install markserv
RUN apt install -y nodejs npm
RUN npm install --global markserv

# Install jupyter
RUN apt install -y python python-dev python-pip ipython
RUN pip install jupyter

# Install terminator
RUN apt install -y terminator

# Install websockify
RUN git clone https://github.com/novnc/websockify.git /opt/websockify && \
    cd /opt/websockify && \
    python setup.py install

# Clone noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc

# Install yarp dependencies
RUN echo "deb http://www.icub.org/ubuntu `lsb_release -cs` contrib/science" > /etc/apt/sources.list.d/icub.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 57A5ACB6110576A6
RUN apt update
RUN apt install -y icub-common

# Select branch + build type
ARG BRANCH=devel
ARG BUILD_TYPE=Release

# Build ycm
RUN git clone https://github.com/robotology/ycm.git -b $BRANCH
RUN cd ycm && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install
RUN rm -Rf ycm

# Build robot-testing
RUN git clone https://github.com/robotology/robot-testing.git -b $BRANCH
RUN cd robot-testing && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
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
RUN cp yarp/scripts/yarp_completion /etc/bash_completion.d/.
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

# Build icub-contrib-common
RUN git clone https://github.com/robotology/icub-contrib-common.git
RUN cd icub-contrib-common && mkdir build && cd build && \
    cmake .. && \
    make install
RUN rm -Rf icub-contrib-common

ARG GITHUB_TOKEN

# Build audition-projects-helpers
RUN git config --global url."https://$GITHUB_TOKEN:@github.com/".insteadOf "https://github.com/"
RUN git clone https://github.com/dic-iit/audition-projects-helpers.git
RUN git config --global --remove-section url."https://$GITHUB_TOKEN:@github.com/"
RUN cd audition-projects-helpers && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install
RUN rm -Rf audition-projects-helpers

# Set up .bashrc
RUN echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \$ '" >> ~/.bashrc

# Set environmental variables
ENV DISPLAY=:1
ENV YARP_DATA_DIRS=/usr/local/share/yarp:/usr/local/share/iCub:/usr/local/share/ICUBcontrib
ENV LD_LIBRARY_PATH=/usr/local/lib/yarp:/usr/local/lib/robottestingframework

# Manage markserv port
EXPOSE 8080

# Manage jupyter port
EXPOSE 8888

# Manage x11vnc port
EXPOSE 5901

# Manage noVNC port
EXPOSE 6080

# Manage yarp port
EXPOSE 10000/tcp 10000/udp

# Launch bash from /projects
WORKDIR /projects
CMD ["bash"]
