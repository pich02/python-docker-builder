FROM debian:bookworm as scip-builder

ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT
ENV TARGETARCH=$TARGETARCH

RUN echo "Building for TARGETPLATFORM=${TARGETPLATFORM}, TARGETARCH=${TARGETARCH}, TARGETVARIANT=${TARGETVARIANT}"

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
  --mount=target=/var/cache/apt,type=cache,sharing=locked \
  apt update; \
  apt install -y git cmake build-essential libz-dev libgmp-dev libreadline-dev libncurses-dev; \
  apt-get install -y wget g++ m4 xz-utils unzip zlib1g-dev libboost-regex-dev libboost-iostreams-dev libtbb-dev libreadline-dev pkg-config git liblapack-dev libgsl-dev flex bison libcliquer-dev gfortran file libopenblas-dev rpm

RUN git clone --depth 1 --branch release-714 https://github.com/scipopt/soplex.git; \
    cd soplex; \
    mkdir build; \
    cd build; \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBOOST=off -DCOVERAGE=off -DCMAKE_CXX_FLAGS=-fPIC; \
    make -j$(grep -c ^processor /proc/cpuinfo); \
    make -j$(grep -c ^processor /proc/cpuinfo) install;

RUN git clone --depth 1 --branch v922 https://github.com/scipopt/scip.git;

RUN mkdir scip/build; \
    mkdir scip/lib; \
    mkdir scip/lib/include; \
    mkdir scip/lib/static; \
    mkdir scip-install;

COPY create_symlink.sh /

RUN /create_symlink.sh ${TARGETARCH};

RUN cd scip; \
    cmake -Bbuild . -DAUTOBUILD=on -DCOVERAGE=off -DSHARED=true -DREADLINE=false -DSOPLEX_DIR=/usr/local/lib/; \
    make -j$(grep -c ^processor /proc/cpuinfo) LPS=spx READLINE=false ZIMPL=false MAKESOFTLINKS=true SHARED=true;

RUN cd scip;\
    yes | make install INSTALLDIR=/scip;

RUN /scip/bin/scip --version;

CMD ["/scip/bin/scip"]