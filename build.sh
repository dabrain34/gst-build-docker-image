#!/bin/bash
DEFAULT_TAG="20.04-master"
echo "Please specify a tag version...(default ubuntu-gst-build/$DEFAULT_TAG)"
read TAG
if [ -z $TAG ]; then
TAG=$DEFAULT_TAG
fi

docker build -t ubuntu-gst-build:$TAG $(dirname $0)
