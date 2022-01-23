# e2xvfb Docker image

[![Docker Build Status](https://github.com/technic/e2xvfb/actions/workflows/docker-image.yml/badge.svg)](https://github.com/technic/e2xvfb/actions/workflows/docker-image.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/technic93/e2xvfb.svg)](https://hub.docker.com/r/technic93/e2xvfb)

Run enigma2 application via SDL under Xvfb xserver.

If you want to be able to connect to the image with vnc first start it with
```bash
docker run --rm -p 5900:5900 --name enigma2_box technic93/e2xvfb x11vnc -forever
```
Then to start enigma2 in the container use
```bash
docker exec -e ENIGMA_DEBUG_LVL=5 enigma2_box enigma2
```
Finally, to stop and remove the container use
```bash
docker stop enigma2_box
```
We also support `RESOLUTION` environment variable for Xvfb.
