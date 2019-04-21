# e2xvfb Docker image

[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/technic93/e2xvfb.svg)](https://cloud.docker.com/repository/docker/technic93/e2xvfb/builds)
[![Docker Pulls](https://img.shields.io/docker/pulls/technic93/e2xvfb.svg)](https://hub.docker.com/r/technic93/e2xvfb)

Run enigma2 application via SDL under Xvfb xserver.

If you want to be able to connect to the image with vnc first start it with
```bash
docker run --rm -p 5900:5900 --name enigma2_box technic93/e2xvfb x11vnc -forever
```
When to start enigma2 in the container use
```bash
docker exec -e DISPLAY=:99 -e ENIGMA_DEBUG_LVL=5 enigma2_box sudo -E enigma2
```
We also support `RESOLUTION` environment variable for Xvfb.
