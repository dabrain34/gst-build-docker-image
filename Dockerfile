ARG UBUNTU_VERSION=ubuntu:20.04
FROM $UBUNTU_VERSION

MAINTAINER dabrain34
ENV DEBIAN_FRONTEND noninteractive

ARG UBUNTU_VERSION=ubuntu:20.04
ARG GST_BUILD_BRANCH_EXT=master
ENV GST_BUILD_BRANCH $GST_BUILD_BRANCH_EXT

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

RUN if [ "x$UBUNTU_VERSION" = "xubuntu:20.04" ] ; then apt-get install -y libaom-dev  ; fi

RUN apt-get install -y curl \
                       cmake \
                       nettle-dev \
                       libgnutls28-dev \
                       pkg-config

RUN curl -L https://github.com/Haivision/srt/archive/refs/tags/v1.4.3.tar.gz | tar xz
WORKDIR /workdir/srt-1.4.3

RUN mkdir -p build && \
    cd build && \
    cmake .. -DUSE_ENCLIB=gnutls && \
    make -j 2 install

# gst-build configure and build
RUN echo "Building gst-build version $GST_BUILD_BRANCH" && \
    git clone https://gitlab.freedesktop.org/gstreamer/gst-build.git && \
    cd gst-build && git checkout $GST_BUILD_BRANCH && \
    meson build_dir -Ddevtools=disabled -Dvaapi=disabled  && \
    ninja -C build_dir && \
    ninja -C build_dir install && \
    ldconfig

