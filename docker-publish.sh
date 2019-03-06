#!/bin/bash
VERSION=latest
docker build . -t technic93/e2xvfb:${VERSION}
docker push technic93/e2xvfb:${VERSION}
