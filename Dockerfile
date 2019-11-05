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
WORKDIR /root/
COPY --from=builder /usr/local/src/SoftEtherVPN/build .
RUN apk update && apk add --no-cache \
    readline \
    openssl \
    bash \
    jq \
    dhclient coreutils && \
    apk add --no-cache gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
COPY entrypoint.sh ./entrypoint.sh
ENV LD_PRELOAD=/usr/lib/preloadable_libiconv.so \
    LD_LIBRARY_PATH=/root \
    CLIENT_NICNAME=vpn0 \
    ROUTES=()
VOLUME ["/server", "/client"]
RUN ln -s /server/vpn_server.config vpn_server.config && \
    ln -s /client/vpn_client.config vpn_client.config && \
    chmod +x entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["server"]
