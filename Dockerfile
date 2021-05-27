FROM ubuntu:20.04

MAINTAINER dabrain34

ENV DEBIAN_FRONTEND noninteractive
ENV GST_BUILD_BRANCH master

# Create the worker dir
RUN mkdir /workdir
RUN chmod 777 /workdir
WORKDIR /workdir

# Install essential build packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        build-essential \
        git \
        net-tools \
        python3-pip \
        ninja-build
RUN pip3 install meson

# gst-build dependencies
RUN apt-get install -y \
        glib2.0-dev \
        flex \
        bison

# gst-build plugins dependencies
RUN apt-get install -y \
    libsrt-dev \
    libaom-dev \
    libcaca-dev \
    libgtk-3-dev \
    libgtest-dev \
    libgraphene-1.0-dev \
    libgsl-dev \
    libfaac-dev \
    libnice-dev \
    libopencv-dev \
    libsbc-dev \
    libx264-dev

# gst-build configure and build
RUN git clone https://gitlab.freedesktop.org/gstreamer/gst-build.git && cd gst-build && git checkout $GST_BUILD_BRANCH && \
    meson build_dir --prefix=/usr -Ddevtools=disabled -Dvaapi=disabled  && \
    ninja -C build_dir && \
    ninja -C build_dir install

