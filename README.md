# e2xvfb Docker image
Run enigma2 application via SDL under Xvfb xserver.

If you want to be able to connect to the image with vnc first start it with
```bash
docker run -p 5900:5900 --name enigma2_box x11vnc -forever
```
When to start enigma2 in the container use
```bash
docker exec -e DISPLAY=:99 -e ENIGMA_DEBUG_LVL=5 enigma2_box sudo -E enigma2
```
We also support `RESOLUTION` environment variable for Xvfb.
