FROM debian:bookworm as scip-builder

ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT

RUN echo "Building for TARGETPLATFORM=${TARGETPLATFORM}, TARGETARCH=${TARGETARCH}, TARGETVARIANT=${TARGETVARIANT}"

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
  --mount=target=/var/cache/apt,type=cache,sharing=locked \
  apt update; \
  apt install -y git make cmake build-essential libz-dev libgmp-dev libreadline-dev libncurses-dev; \
  apt-get install -y wget g++ m4 xz-utils unzip zlib1g-dev libboost-program-options-dev libboost-serialization-dev libboost-regex-dev libboost-iostreams-dev libtbb-dev libreadline-dev pkg-config git liblapack-dev libgsl-dev flex bison libcliquer-dev gfortran file dpkg-dev libopenblas-dev rpm

RUN git clone --depth 1 --branch release-700 https://github.com/scipopt/soplex.git; \
    cd soplex; \
    mkdir build; \
    cd build; \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBOOST=false -DCOVERAGE=off; \
    make -j$(grep -c ^processor /proc/cpuinfo); \
    make install

COPY packages/scip-9.0.0.tgz /
RUN tar xvf scip-9.0.0.tgz

RUN mkdir scip-9.0.0/build; \
    mkdir scip-9.0.0/lib; \
    mkdir scip-9.0.0/lib/include; \
    mkdir scip-9.0.0/lib/static

RUN ln -s /usr/local/include/soplex/ /scip-9.0.0/lib/include/spxinc; \
    ln -s /usr/local/lib/libsoplex.a /scip-9.0.0/lib/static/libsoplex.linux.${TARGETARCH}.gnu.a; \
    ln -s /usr/local/lib/libsoplex.a /usr/local/lib/libsoplex.linux.${TARGETARCH}.gnu.opt.a

RUN cd scip-9.0.0; \
    cmake -Bbuild . -DAUTOBUILD=on -DCOVERAGE=off -DSHARED=false -DREADLINE=false; \
    make -j$(grep -c ^processor /proc/cpuinfo) LPS=spx READLINE=false ZIMPL=false MAKESOFTLINKS=false; \
    make -j$(grep -c ^processor /proc/cpuinfo) install INSTALLDIR=/scip/

RUN /scip/bin/scip --version

CMD ["/scip/bin/scip"]