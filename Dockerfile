FROM ubuntu:latest
LABEL org.opencontainers.image.title="IIT Technical Evaluation Docker Image"
LABEL org.opencontainers.image.description="Stack of components required to run technical evaluations on Gitpod"
LABEL org.opencontainers.image.source="https://github.com/pattacini/technical-evaluation"
LABEL org.opencontainers.image.authors="Ugo Pattacini <ugo.pattacini@iit.it>"

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Update apt database
RUN apt update

# Install essentials
RUN apt install -y apt-utils software-properties-common apt-transport-https sudo \
    psmisc lsb-release tmux nano wget curl telnet gnupg build-essential gdb git gitk \
    cmake cmake-curses-gui libedit-dev libxml2-dev autoconf locales gdebi terminator meld \
    dos2unix bash-completion iputils-ping

# Set the locale
RUN locale-gen en_US.UTF-8

# Install VSCode
# better off downling the deb file than relying on packages.microsoft.com sources that are often broken
RUN wget -O code.deb https://go.microsoft.com/fwlink/?LinkID=760868 && \
    gdebi -n code.deb && \
    rm code.deb

# Install graphics
RUN apt install -y xfce4 xfce4-goodies xserver-xorg-video-dummy xserver-xorg-legacy x11vnc firefox && \
    apt remove -y xfce4-power-manager xfce4-screensaver light-locker && \
    apt autoremove -y && \
    sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
COPY xorg.conf /etc/X11/xorg.conf
RUN dos2unix /etc/X11/xorg.conf

# Install Java
RUN apt install -y default-jdk

# Install Octave
RUN apt install -y octave epstool transfig

# Install markserv
RUN apt install -y nodejs npm && \
    npm install --global markserv

# Install jupyter
RUN apt install -y python3 python3-dev python3-pip python3-setuptools && \
    if [ ! -f "/usr/bin/python" ]; then ln -s /usr/bin/python3 /usr/bin/python; fi && \
    pip3 install ipython jupyter
    
# Install magic-wormwhole to get things from one computer to another safely
RUN apt install -y magic-wormhole

# Install noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify && \
    echo "<html><head><meta http-equiv=\"Refresh\" content=\"0; url=vnc.html?autoconnect=true&reconnect=true&reconnect_delay=1000&resize=scale&quality=9\"></head></html>" > /opt/novnc/index.html

# Install dependencies
RUN apt install -y libeigen3-dev build-essential cmake cmake-curses-gui coinor-libipopt-dev freeglut3-dev \
    libboost-system-dev libboost-filesystem-dev libboost-thread-dev libtinyxml-dev libsqlite3-dev libace-dev libedit-dev \
    libgsl0-dev libopencv-dev libode-dev liblua5.1-dev lua5.1 git swig qtbase5-dev qtdeclarative5-dev \
    qtmultimedia5-dev qml-module-qtquick2 qml-module-qtquick-window2 qml-module-qtmultimedia \
    qml-module-qtquick-dialogs qml-module-qtquick-controls qml-module-qt-labs-folderlistmodel \
    qml-module-qt-labs-settings libsdl1.2-dev libxml2-dev libv4l-dev

# Arguments
ARG BRANCH=devel
ARG BUILD_TYPE=Release

# Build ycm
RUN git clone https://github.com/robotology/ycm.git --depth 1 && \
    cd ycm && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} && \
    make install && \
    cd ../.. && rm -Rf ycm

# Build robot-testing-framework
RUN git clone https://github.com/robotology/robot-testing-framework.git --depth 1 --branch ${BRANCH} && \
    cd robot-testing-framework && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} && \
    make install && \
    cd ../.. && rm -Rf robot-testing-framework

# Build yarp
RUN git clone https://github.com/robotology/yarp.git --depth 1 && \
    cd yarp && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} && \
    make install && \
    cd ../.. && rm -Rf yarp

# Build icub-main
RUN git clone https://github.com/robotology/icub-main.git --depth 1 --branch ${BRANCH} && \
    cd icub-main && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DENABLE_icubmod_cartesiancontrollerserver=ON \
    -DENABLE_icubmod_cartesiancontrollerclient=ON \
    -DENABLE_icubmod_gazecontrollerclient=ON && \
    make install && \
    cd ../.. && rm -Rf icub-main

# Build audition-projects-helpers
RUN --mount=type=secret,id=HELPERS_REPO_PAT \
    export HELPERS_REPO_PAT=$(cat /run/secrets/HELPERS_REPO_PAT) && \
    git config --global url."https://${HELPERS_REPO_PAT}:@github.com/".insteadOf "https://github.com/" && \
    git clone https://github.com/pattacini/audition-projects-helpers.git --depth 1 && \
    git config --global --remove-section url."https://${HELPERS_REPO_PAT}:@github.com/" && \
    cd audition-projects-helpers && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} && \
    make install && \
    cd ../.. && rm -Rf audition-projects-helpers

# Set environmental variables
ENV DISPLAY=:1
ENV ICUBcontrib_DIR=/workspace/iCubContrib
ENV YARP_COLORED_OUTPUT=1
ENV YARP_DATA_DIRS=/usr/local/share/yarp:/usr/local/share/iCub:${ICUBcontrib_DIR}/share/ICUBcontrib
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib/yarp:/usr/local/lib/robottestingframework:${ICUBcontrib_DIR}/lib

# Create user gitpod
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod && \
    # passwordless sudo for users in the 'sudo' group
    sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Switch to gitpod user
USER gitpod

# Install Homebrew
RUN mkdir ~/.cache && sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
ENV PATH="${PATH}:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin/"
ENV MANPATH="${MANPATH}:/home/linuxbrew/.linuxbrew/share/man"
ENV INFOPATH="${INFOPATH}:/home/linuxbrew/.linuxbrew/share/info"
ENV HOMEBREW_NO_AUTO_UPDATE=1

# Install informative git for bash
RUN git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1

# Set up .bashrc
# "/usr/bin" needs to come in the first place within PATH to shadow "/ide/bin/code"
WORKDIR /home/gitpod
RUN echo "GIT_PROMPT_ONLY_IN_REPO=1" >> ~/.bashrc && \
    echo "source \${HOME}/.bash-git-prompt/gitprompt.sh" >> ~/.bashrc && \
    echo "export PATH=/usr/bin:\${PATH}:\${ICUBcontrib_DIR}/bin" >> ~/.bashrc

# Switch back to root
USER root

# Set up script to prepare /workspace/iCubContrib
COPY init-icubcontrib.sh /usr/bin/init-icubcontrib.sh
RUN chmod +x /usr/bin/init-icubcontrib.sh && \
    dos2unix /usr/bin/init-icubcontrib.sh

# Set up script to launch markserv
COPY start-markserv.sh /usr/bin/start-markserv.sh
RUN chmod +x /usr/bin/start-markserv.sh && \
    dos2unix /usr/bin/start-markserv.sh

# Set up script to launch jupyter
COPY start-jupyter.sh /usr/bin/start-jupyter.sh
RUN chmod +x /usr/bin/start-jupyter.sh && \
    dos2unix /usr/bin/start-jupyter.sh

# Set up script to launch graphics and vnc
COPY start-vnc-session.sh /usr/bin/start-vnc-session.sh
RUN chmod +x /usr/bin/start-vnc-session.sh && \
    dos2unix /usr/bin/start-vnc-session.sh

# Set up VSCode launcher
COPY ["Visual Studio Code.desktop", "/home/gitpod/Desktop/Visual Studio Code.desktop"]
RUN chmod +x "/home/gitpod/Desktop/Visual Studio Code.desktop" && \
    dos2unix "/home/gitpod/Desktop/Visual Studio Code.desktop"

# Make sure specific dirs are owned by gitpod user
RUN chown -R gitpod.gitpod /home/gitpod/Desktop

# Manage ports
EXPOSE 8080 8888 5901 6080 10000/tcp 10000/udp

# Clean up unnecessary installation products
RUN rm -Rf /var/lib/apt/lists/*

# Launch bash from /workspace
WORKDIR /workspace
CMD ["bash"]
