from ubuntu:14.04
maintainer kami911@gmail.com

label vendor=KAMI911 \
      hu.kami911.opencv.is-beta= \
      hu.kami911.opencv..version="0.0.1-beta" \
      hu.kami911.opencv.release-date="2016-11-19"

run apt-get update
run apt-get upgrade -q -y

run apt-get install -q -y \
 build-essential \
 cmake \
 git \
 libgtk2.0-dev \
 pkg-config \
 libavcodec-dev \
 libavformat-dev \
 libswscale-dev \
 python-dev \
 python-pip \
 python3-pip \
 libtbb2 \
 libtbb-dev \
 libjpeg-dev \
 libpng-dev \
 libtiff-dev \
 libjasper-dev \
 libdc1394-22-dev \
 zip \
 unzip \
 wget

run pip install numpy
run pip3 install numpy

add build_opencv.sh /opt/build_opencv.sh
run /bin/sh /opt/build_opencv.sh

add cascade_trainer.sh /opt/data/cascade_trainer.sh

