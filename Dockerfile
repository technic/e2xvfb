FROM ubuntu:16.04

RUN useradd -G video -m -s /bin/bash e2user
RUN apt-get update && apt-get -y install sudo
RUN adduser e2user sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# build requirements
RUN apt-get install -y \
  git build-essential autoconf autotools-dev libtool libtool-bin checkinstall unzip \
  swig python-dev python-twisted \
  libz-dev libssl-dev \
  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libsigc++-2.0-dev \
  libfreetype6-dev libsigc++-1.2-dev libfribidi-dev \
  libavahi-client-dev libjpeg-dev libgif-dev libsdl2-dev

RUN apt-get install -y libsdl1.2-dev

# xserver
RUN apt-get install -y x11vnc xvfb
# web server
RUN apt-get install -y apache2

# enigma2 wants python-wifi
RUN apt-get -y install python-pip && pip install python-wifi

# opkg dependencies
RUN apt-get install -y libarchive-dev libcurl4-openssl-dev libgpgme11-dev

WORKDIR /work

ARG OPKG_VER="0.3.5"
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

RUN git clone --depth 10 https://github.com/technic/enigma2.git
RUN cd enigma2 \
 && ./autogen.sh \
 && ./configure --with-libsdl --with-gstversion=1.0 --prefix=/usr --sysconfdir=/etc \
 && make -j4 \
 && make install
# disable startup wizards
COPY enigma2-settings /etc/enigma2/settings
RUN ldconfig

RUN apt-get install -y xdotool

COPY entrypoint.sh /opt
RUN chmod 755 /opt/entrypoint.sh
ENV DISPLAY=:99
EXPOSE 5900 80
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD bash
