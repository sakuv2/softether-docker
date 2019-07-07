FROM alpine as builder
RUN mkdir /usr/local/src && apk update && apk add binutils \
    build-base \
    readline-dev \
    openssl-dev \
    ncurses-dev \
    git \
    zlib-dev \
    cmake &&\
    apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so
WORKDIR /usr/local/src
RUN git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git
WORKDIR /usr/local/src/SoftEtherVPN
RUN git submodule update --init --recursive && ./configure && make -C tmp

FROM alpine
RUN apk update && apk add --no-cache \
    readline \
    openssl \
    dhclient coreutils && \
    apk add --no-cache gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so
ENV LD_LIBRARY_PATH /root
WORKDIR /root/
VOLUME ["/server", "/client"]
RUN ln -s /server/vpn_server.config vpn_server.config && \
    mkdir /server/backup.vpn_server.config && \
    ln -s /server/backup.vpn_server.config backup.vpn_server.config && \
    ln -s /server/lang.config lang.config && \
    ln -s /client/vpn_client.config vpn_client.config
COPY --from=builder /usr/local/src/SoftEtherVPN/build .
CMD ["/root/vpnserver", "execsvc"]
