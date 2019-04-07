FROM ubuntu:latest
LABEL maintainer="ugo.pattacini@iit.it"

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Update apt database
RUN apt update

# Install essentials
RUN apt install -y apt-utils lsb-release build-essential git cmake cmake-curses-gui libedit-dev libxml2-dev

# Install Java
RUN apt install -y default-jdk

# Install Octave
RUN apt install -y octave epstool transfig

# Install markserv
RUN apt install -y nodejs npm
RUN npm i -g markserv

# Install jupyter
RUN apt install -y python python-dev python-pip ipython
RUN pip install jupyter

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
    cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install
RUN rm -rf ycm

# Build robot-testing
RUN git clone https://github.com/robotology/robot-testing.git -b $BRANCH
RUN cd robot-testing && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install
RUN rm -rf robot-testing

# Build yarp
RUN git clone https://github.com/robotology/yarp.git -b $BRANCH
RUN cd yarp && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DYARP_COMPILE_RTF_ADDONS=ON \
    -DCREATE_LIB_MATH=ON \
    -DCREATE_GUIS=OFF \
    -DYARP_COMPILE_DEVICE_PLUGINS=OFF && \
    make install
RUN rm -rf yarp

# Build icub-main
RUN git clone https://github.com/robotology/icub-main.git -b $BRANCH
RUN cd icub-main && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install
RUN rm -rf icub-main

# Build icub-contrib-common
RUN git clone https://github.com/robotology/icub-contrib-common.git
RUN cd icub-contrib-common && mkdir build && cd build && \
    cmake .. && \
    make install
RUN rm -rf icub-contrib-common

# Ports management
EXPOSE 8080 8888 10000/tcp 10000/udp

# Setup an additional entrypoint script
COPY entrypoint.sh /usr/sbin/entrypoint.sh
RUN chmod 755 /usr/sbin/entrypoint.sh
ENTRYPOINT ["/usr/sbin/entrypoint.sh"]

WORKDIR /projects
CMD ["bash"]
