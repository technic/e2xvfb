FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# build requirements
RUN apt-get update && apt-get install -y \
  git build-essential autoconf autotools-dev libtool libtool-bin unzip \
  swig python3-dev python3-pip python3-twisted \
  libz-dev libssl-dev \
  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libsigc++-2.0-dev \
  libfreetype6-dev libfribidi-dev \
  libavahi-client-dev libjpeg-dev libgif-dev libsdl2-dev libxml2-dev \
  libarchive-dev libcurl4-openssl-dev libgpgme11-dev \
  x11vnc xvfb xdotool

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
 && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

WORKDIR /work

ARG OPKG_VER="0.4.5"
RUN curl "http://git.yoctoproject.org/cgit/cgit.cgi/opkg/snapshot/opkg-$OPKG_VER.tar.gz" -o opkg.tar.gz
RUN tar -xzf opkg.tar.gz \
 && cd "opkg-$OPKG_VER" \
 && ./autogen.sh \
 && ./configure --enable-curl --enable-ssl-curl --enable-gpg \
 && make \
 && make install

RUN git clone --depth 10 git://git.opendreambox.org/git/obi/libdvbsi++.git
RUN cd libdvbsi++ \
 && ./autogen.sh \
 && ./configure \
 && make \
 && make install

RUN git clone --depth 10 git://github.com/OpenPLi/tuxtxt.git
RUN cd tuxtxt/libtuxtxt \
 && autoreconf -i \
 && CPP="gcc -E -P" ./configure --with-boxtype=generic --prefix=/usr \
 && make \
 && make install
RUN cd tuxtxt/tuxtxt \
 && autoreconf -i \
 && CPP="gcc -E -P" ./configure --with-boxtype=generic --prefix=/usr \
 && make \
 && make install

RUN git clone --depth 10 https://github.com/technic/enigma2-atv.git enigma2
RUN cd enigma2 \
 && ./autogen.sh \
 && ./configure --with-libsdl --with-gstversion=1.0 --prefix=/usr --sysconfdir=/etc \
 && make -j4 \
 && make install
# disable startup wizards
COPY enigma2-settings /etc/enigma2/settings
RUN ldconfig

COPY entrypoint.sh /opt
RUN chmod 755 /opt/entrypoint.sh
ENV DISPLAY=:99
EXPOSE 5900 80
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD bash
