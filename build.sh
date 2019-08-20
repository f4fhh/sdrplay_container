#!/bin/bash
set -euxo pipefail

ARCH=$(uname -m)

case $ARCH in
  x86_64)
    BASE_IMAGE=ubuntu:18.04
    ;;
  armv*)
    BASE_IMAGE=arm32v7/ubuntu:18.04
esac

TAGS=$ARCH

docker build --build-arg BASE_IMAGE=$BASE_IMAGE --build-arg ARCH=$ARCH -t f4fhh/sdrplay:$ARCH .
