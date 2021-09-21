ARG UBUNTU_VERSION=ubuntu:18.04
FROM $UBUNTU_VERSION

MAINTAINER dabrain34
ENV DEBIAN_FRONTEND noninteractive

ARG UBUNTU_VERSION=ubuntu:18.04
ARG GST_BUILD_BRANCH_EXT=master
ENV GST_BUILD_BRANCH $GST_BUILD_BRANCH_EXT

# Create the worker dir
RUN ln -sf /bin/bash /bin/sh
RUN mkdir /workdir
RUN chmod 777 /workdir
WORKDIR /workdir

# Install essential build packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential \
        sudo \
        git \
        wget \
        unzip \
        net-tools \
        ninja-build \
        python3-pip \
        yasm \
        gcc-aarch64-linux-gnu \
        g++-aarch64-linux-gnu

RUN if [ "x$UBUNTU_VERSION" = "xubuntu:16.04" ] ; then \
        apt-get install -y software-properties-common python-software-properties; \
        add-apt-repository -y ppa:deadsnakes/ppa; \
        apt-get update; \
        apt-get -y install python3.6; \
        ln -sf /usr/bin/python3.6 /usr/bin/python3; \
        pip3 install --upgrade pip; \
        wget https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-linux.zip; \
        unzip ninja-linux.zip -d /usr/local/bin/; \
        update-alternatives --install /usr/bin/ninja ninja /usr/local/bin/ninja 1 --force; \
        fi

RUN pip3 install meson==0.58.2

# gst-build dependencies
RUN apt-get install -y \
        glib2.0-dev \
        flex \
        bison



RUN if [ "x$UBUNTU_VERSION" = "xubuntu:20.04" ] ; then apt-get install -y libaom-dev libgraphene-1.0-dev  ; fi

RUN apt-get install -y curl \
                       cmake \
                       nettle-dev \
                       libgnutls28-dev \
                       pkg-config


# gst-build configure and build
WORKDIR /workdir
ADD my-xlnx-cross-file.txt .
RUN git clone https://github.com/Xilinx/vcu-omx-il.git --branch=release-2020.1 vcu-omx-il


RUN echo "Building gst-build version $GST_BUILD_BRANCH" && \
    git clone https://gitlab.freedesktop.org/gstreamer/gst-build.git && \
    cd gst-build && git checkout $GST_BUILD_BRANCH && \
    meson build_dir -D omx=enabled -D sharp=disabled -Dgst-omx:header_path=/workdir/vcu-omx-il/omx_header -D gst-omx:target=zynqultrascaleplus -D libav=disabled -D rtsp_server=disabled -D vaapi=disabled --cross-file=/workdir/my-xlnx-cross-file.txt -Dugly=disabled -Dglib:libmount=disabled  && \
    ninja -C build_dir
