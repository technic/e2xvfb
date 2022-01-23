FROM ubuntu:18.04

# build requirements
RUN apt-get update && apt-get install -y \
  git build-essential autoconf autotools-dev libtool libtool-bin checkinstall unzip \
  swig python-dev python-pip python-twisted \
  libz-dev libssl-dev \
  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libsigc++-2.0-dev \
  libfreetype6-dev libfribidi-dev \
  libavahi-client-dev libjpeg-dev libgif-dev libsdl2-dev libxml2-dev

# xserver, web server
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y x11vnc xvfb xdotool apache2

# enigma2 wants python-wifi
RUN pip install python-wifi

# opkg dependencies
RUN apt-get install -y libarchive-dev libcurl4-openssl-dev libgpgme11-dev

WORKDIR /work

ARG OPKG_VER="0.4.5"
RUN curl -L "http://git.yoctoproject.org/cgit/cgit.cgi/opkg/snapshot/opkg-$OPKG_VER.tar.gz" -o opkg.tar.gz
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

RUN git clone --depth 10 https://github.com/technic/enigma2.git
RUN cd enigma2 \
 && ./autogen.sh \
 && ./configure --with-libsdl --with-gstversion=1.0 --prefix=/usr --sysconfdir=/etc \
 && make -j4 \
 && make install
# disable startup wizards
COPY enigma2-settings /etc/enigma2/settings
RUN ldconfig

RUN git clone --depth 10 https://github.com/technic/servicemp3.git \
 && cd servicemp3 && git checkout 925d1a4732437049ba7ba37557dea37de830177c
RUN cd servicemp3 \
 && ./autogen.sh \
 && ./configure --with-gstversion=1.0 --prefix=/usr \
 && make -j4 \
 && make install

COPY entrypoint.sh /opt
RUN chmod 755 /opt/entrypoint.sh
ENV DISPLAY=:99
EXPOSE 5900 80
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD bash
