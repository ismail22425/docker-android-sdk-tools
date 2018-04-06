FROM ubuntu:16.04
MAINTAINER Slimane.B
ENV APPIUM_VERSION 1.6.3
ARG OPENJDK="8"
ARG ANDROID_SDK_TOOLS="24.4.1"
ARG ANDROID_COMPILE_SDK="25"
#=================================
# Customize sources for apt-get
#=================================
#RUN  echo "deb http://archive.ubuntu.com/ubuntu vivid main universe\n" > /etc/apt/sources.list \
#  && echo "deb http://archive.ubuntu.com/ubuntu vivid-updates main universe\n" >> /etc/apt/sources.list

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
#=================================
# Install all dependencies
#=================================

RUN apt-get update && \
        
        apt-get install -y bash curl npm git patch bzip2 build-essential openssl libssl-dev  \  
	&& apt-get install -y software-properties-common  \
	&& apt-get install -y python-software-properties  \
        && add-apt-repository ppa:openjdk-r/ppa  \
	&& apt-get update -y  \
	&& apt-get install nodejs -y  \
	&& apt-get update -y  \
	&& apt-get install nodejs -y  \
	&& apt-get install curl -y  \
	&& apt-get install git -y  \
	&& apt-get install unzip -y  \
	&& apt-get install openjdk-${OPENJDK}-jre -y  \
	&& apt-get install python-pip -y  \
	&& pip install --upgrade pip   \
	&& pip install cryptography \
	&& pip install robotframework   \
	&& pip install robotframework-selenium2library  \
	&& pip install robotframework-sshlibrary  \
	&& pip install robotframework-appiumlibrary  

#=============================================
# Install Android SDK's and Platform tools
#=============================================

RUN export DEBIAN_FRONTEND=noninteractive \
  && dpkg --add-architecture i386 \
  && apt-get update -y \
  && apt-get -y --no-install-recommends install \
    libc6-i386 \
    lib32stdc++6 \
    lib32gcc1 \
    lib32ncurses5 \
    lib32z1 \
    wget \
    curl \
    ant \	
    unzip \
    openjdk-${OPENJDK}-jre-headless \
  && wget --progress=dot:giga -O /opt/adt.tgz \
    http://dl.google.com/android/android-sdk_r${ANDROID_SDK_TOOLS}-linux.tgz \
  && tar xzf /opt/adt.tgz -C /opt \
  && rm /opt/adt.tgz \
  && ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | /opt/android-sdk-linux/tools/android update sdk   -a -u --filter android-${ANDROID_COMPILE_SDK},platform,platform-tools \
  && apt-get -qqy clean \
  && rm -rf /var/cache/apt/*

#================================
# Set up PATH for Android Tools
#================================
ENV HOME /home/user

WORKDIR $HOME


ENV PATH $PATH:/opt/android-sdk-linux/platform-tools:/opt/android-sdk-linux/tools
ENV ANDROID_HOME /opt/android-sdk-linux

#==========================
# Install Appium Dependencies
#==========================

#RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo bash - \
RUN curl -sL https://deb.nodesource.com/setup_6.x  \
  && apt-get update && apt-get -qqy install -y \
    nodejs -y  \
    make \
    build-essential \
    g++ \ 
  && ln -s /usr/bin/nodejs /usr/bin/node
#=====================
# Install Appium
#=====================

RUN mkdir /opt/appium \
  && cd /opt/appium \
  && npm cache clean \
  && npm install appium@$APPIUM_VERSION \
  && ln -s /opt/appium/node_modules/.bin/appium /usr/bin/appium

EXPOSE 4723

#==========================
# Run appium as default
#==========================
#CMD /usr/bin/appium&
