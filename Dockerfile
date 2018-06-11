FROM ubuntu:18.04 AS build
LABEL maintainer="f4fhh@ducor.fr"
LABEL sdrplayAPIversion="2.13"
ENV MAJVERS 2.13
ENV MINVERS .1
RUN apt-get update && apt-get install -y \
        wget \
        build-essential \
        git \
        cmake \
        sudo \
        udev \
        libusb-1.0-0-dev \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /tmp/sdrlib
RUN wget https://www.sdrplay.com/software/SDRplay_RSP_API-Linux-${MAJVERS}${MINVERS}.run && \
        export ARCH=`arch` && \
        sh ./SDRplay_RSP_API-Linux-${MAJVERS}${MINVERS}.run --tar xvf && \
        cp ${ARCH}/libmirsdrapi-rsp.so.${MAJVERS} /usr/local/lib/. && \
        chmod 644 /usr/local/lib/libmirsdrapi-rsp.so.${MAJVERS} && \
        ln -s /usr/local/lib/libmirsdrapi-rsp.so.${MAJVERS} /usr/local/lib/libmirsdrapi-rsp.so.2 && \
        ln -s /usr/local/lib/libmirsdrapi-rsp.so.2 /usr/local/lib/libmirsdrapi-rsp.so && \
        cp mirsdrapi-rsp.h /usr/local/include/. && \
        chmod 644 /usr/local/include/mirsdrapi-rsp.h
WORKDIR /tmp/dump1090fr24
RUN wget -O - https://www.sdrplay.com/software/dump1090_1.3.linux.tar.gz | tar xvfz - --strip 2
RUN wget -O - https://repo-feed.flightradar24.com/linux_x86_64_binaries/fr24feed_1.0.18-5_amd64.tgz | tar xvfz - --strip 1
WORKDIR /tmp
RUN git clone git://git.osmocom.org/rtl-sdr.git ./rtlsdr
WORKDIR /tmp/rtlsdr/build
RUN cmake .. -DDETACH_KERNEL_DRIVER=ON && make && make install
WORKDIR /tmp
RUN git clone https://github.com/pothosware/SoapySDR.git ./SoapySDR
WORKDIR /tmp/SoapySDR/build
RUN cmake .. && make && make install
WORKDIR /tmp
RUN git clone https://github.com/pothosware/SoapySDRPlay.git ./SoapySDRPlay
WORKDIR /tmp/SoapySDRPlay/build
RUN cmake .. && make && make install
WORKDIR /tmp
RUN git clone https://github.com/pothosware/SoapyRTLSDR.git ./SoapyRTLSDR
WORKDIR /tmp/SoapyRTLSDR/build
RUN cmake .. && make && make install
WORKDIR /tmp
RUN git clone https://github.com/pothosware/SoapyRemote.git ./SoapyRemote
WORKDIR /tmp/SoapyRemote/build
RUN cmake .. && make && make install
WORKDIR /tmp
RUN git clone https://github.com/f4fhh/rsp_tcp.git ./rsptcp
WORKDIR /tmp/rsptcp/build
RUN cmake .. && make && make install

FROM ubuntu:18.04 AS production
COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /usr/local/lib/ /usr/lib/x86_64-linux-gnu/libusb-1.0.a /lib/x86_64-linux-gnu/libusb-1.0.so.0.1.0 /usr/local/lib/
RUN \
        ln -s /usr/local/lib/libusb-1.0.so.0.1.0 /usr/local/lib/libusb-1.0.so.0 && \
        ln -s /usr/local/lib/libusb-1.0.so.0.1.0 /usr/local/lib/libusb-1.0.so && \
        ldconfig
COPY --from=build /tmp/dump1090fr24/ /usr/lib/fr24/
COPY config.js /usr/lib/fr24/public_html/
COPY fr24feed.ini /etc/
COPY LICENSE LICENSE_fr24feed LICENSE_sdrplay /usr/local/share/
EXPOSE 1234 8080 8754 55132
