ARG PLATFORM=amd64
FROM ${PLATFORM}/alpine:edge

WORKDIR /build

RUN apk add --no-cache wget cmake make gcc g++ linux-headers zlib-dev openssl-dev \
            automake autoconf libevent-dev ncurses-dev msgpack-c-dev \
            ncurses-static libevent-static msgpack-c ncurses-libs \
            libevent openssl zlib musl-dev libssh2-static zlib-static openssl-libs-static

RUN set -ex; \
            mkdir -p /src/libssh/build; \
            cd /src; \
            wget -O libssh.tar.xz https://www.libssh.org/files/0.10/libssh-0.10.5.tar.xz; \
            tar -xf libssh.tar.xz -C /src/libssh --strip-components=1; \
            cd /src/libssh/build; \
            cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr \
            -DWITH_SFTP=OFF -DWITH_SERVER=OFF -DWITH_PCAP=OFF \
            -DBUILD_STATIC_LIB=ON -DBUILD_SHARED_LIBS=OFF -DWITH_EXAMPLES=OFF -DWITH_GSSAPI=OFF ..; \
            make -j $(nproc); \
            make install

COPY compat ./compat
COPY *.c *.h autogen.sh Makefile.am configure.ac ./

RUN ./autogen.sh && ./configure --enable-static
RUN make -j $(nproc)
RUN objcopy --only-keep-debug tmate tmate.symbols && strip tmate
RUN ./tmate -V
