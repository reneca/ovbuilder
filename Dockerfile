##
# \file Dockerfile
# \brief Dockerfile to create debian overware ovbuilder
# \author Jeremy HERGAULT (reneca)
# \version 1.0
# \date 2019-02-17
#
# This file is part of OVBuilder, which is builder for overware programs.
# Copyright (C) 2019  HERGAULT Jeremy, Alexandre, Thierry ( reneca )
#
# OVBuilder is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# OVBuilder is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OVCloud. If not, see <http://www.gnu.org/licenses/>.
##

FROM debian:stable
MAINTAINER HERGAULT Jeremy <reneca@overware.fr>
LABEL Description="OVBuilder for overware programs" Vendor="overware" Version="1.0"

ENV DOCKERCOMPIL=true \
    PATH="${PATH}:/usr/local/bin:/sources/bin"

ARG OPENSSL_PACKAGE=openssl-1.1.1a
ARG ZLIB_PACKAGE=1.2.8

COPY scripts/select-product.sh scripts/analyse-stacktrace scripts/build-doc scripts/build-cppanalysis scripts/build-product scripts/build-rfc /usr/local/bin/

RUN apt-get -y update && apt-get -y install \
      ca-certificates \
      procps \
      wget \
      curl \
      perl \
      cppcheck \
      doxygen \
      graphviz \
      build-essential \
      vim \
      git \
      make \
      gcc \
      g++ \
      elfutils \
      libc-dbg \
      python-pip \
      ruby-kramdown-rfc2629 \
 && apt-get -y clean \
 && apt-get -y autoclean \
 && mkdir -p /sources/objs /opt \
 && curl https://www.openssl.org/source/${OPENSSL_PACKAGE}.tar.gz -o /tmp/openssl.tar.gz \
 && tar zxf /tmp/openssl.tar.gz -C /sources \
 && cd /sources/${OPENSSL_PACKAGE} \
 && ./config --prefix=/sources --openssldir=/etc/ssl shared threads no-ssl3 \
 && make \
 && make install \
 && cd /tmp \
 && curl -LO https://github.com/RJVB/zlib-cloudflare/archive/v${ZLIB_PACKAGE}.tar.gz \
 && tar zxf v${ZLIB_PACKAGE}.tar.gz -C /sources \
 && cd /sources/zlib-cloudflare-${ZLIB_PACKAGE} \
 && ./configure --prefix=/sources --shared \
 && make \
 && make install \
 && rm -rf /sources/lib/libz*.a \
 && cp *.lo /sources/objs/ \
 && cd /sources/objs \
 && for lib in $(ls -d /sources/lib/*.a); do ar -x $lib; done \
 && chmod 755 -R /sources/bin \
 && openssl s_client -showcerts -connect ietf.org:443 </dev/null 2>/dev/null| openssl x509 -outform PEM > /usr/local/share/ca-certificates/ietf.org.crt \
 && openssl s_client -showcerts -connect tools.ietf.org:443 </dev/null 2>/dev/null| openssl x509 -outform PEM > /usr/local/share/ca-certificates/tools.ietf.org.crt \
 && update-ca-certificates \
 && pip install xml2rfc \
 && rm -rf /tmp/* \
 && chmod +x /usr/local/bin/analyse-stacktrace /usr/local/bin/build-doc /usr/local/bin/build-cppanalysis /usr/local/bin/build-product /usr/local/bin/build-rfc

WORKDIR /opt

VOLUME /opt/

ENTRYPOINT ["/usr/local/bin/build-product"]


# End of Dockerfile
