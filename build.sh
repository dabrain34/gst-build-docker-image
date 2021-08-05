#!/bin/bash

UBUNTU_VERSION=$1
GST_BUILD_VERSION=$2

DEFAULT_UBUNTU_VERSION="20.04"
DEFAULT_GST_BUILD_VERSION="master"
if [ -z $UBUNTU_VERSION ]; then
echo "Please specify a ubuntu version...(default ubuntu-gst-build/$DEFAULT_UBUNTU_VERSION)"
read UBUNTU_VERSION
UBUNTU_VERSION=$DEFAULT_UBUNTU_VERSION
fi


if [ -z $GST_BUILD_VERSION ]; then
echo "Please specify a gst-build version...(default ubuntu-gst-build/$DEFAULT_GST_BUILD_VERSION)"
read GST_BUILD_VERSION
GST_BUILD_VERSION=$DEFAULT_GST_BUILD_VERSION
fi

TAG=$UBUNTU_VERSION-$GST_BUILD_VERSION
echo $TAG

echo "OK to proceed (y to continue)"
read ANSWER

if [ "$ANSWER" != "y" ]; then
exit
fi

docker build -t ubuntu-gst-build:$TAG --build-arg UBUNTU_VERSION="ubuntu:$UBUNTU_VERSION" --build-arg GST_BUILD_BRANCH_EXT="$GST_BUILD_VERSION" $(dirname $0)
