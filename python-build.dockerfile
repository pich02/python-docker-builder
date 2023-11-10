# BASE IMAGE python 3.X.Y with GLICB 2.24 and openssl 1.1.1q
FROM debian:stretch-slim as builder

ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT

RUN echo "Building for TARGETPLATFORM=${TARGETPLATFORM}, TARGETARCH=${TARGETARCH}, TARGETVARIANT=${TARGETVARIANT}" \
    && echo GLIBC=$(ldd --version)

ENV LANG=C.UTF-8
ENV PYTHON_VERSION=3.11.6

RUN echo "deb http://archive.debian.org/debian/ stretch main contrib non-free\n \
    deb http://archive.debian.org/debian/ stretch-proposed-updates main contrib non-free\n \
    deb http://archive.debian.org/debian-security stretch/updates main contrib non-free\n" >> /etc/apt/sources.list

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean; \
    apt-get update; \
    apt-get -y install software-properties-common; \
    apt-get install -y build-essential; \
    apt-get install -y python3-dev; \
    apt-get install -y libsqlite3-dev; \
    apt-get install -y libreadline-gplv2-dev; \
    apt-get install -y libncursesw5-dev; \
    apt-get install -y libncurses5-dev; \
    apt-get install -y libssl-dev; \
    apt-get install -y libgdbm-dev; \
    apt-get install -y libc6-dev; \
    apt-get install -y libbz2-dev; \
    apt-get install -y libffi-dev; \
    apt-get install -y libxml2-dev; \
    apt-get install -y libxslt1-dev; \
    apt-get install -y zlib1g-dev; \
    apt-get install -y libreadline-dev; \
    apt-get install -y xz-utils; \
    apt-get install -y liblzma-dev; \
    apt-get install -y tk-dev; \
    apt-get install -y llvm; \
    apt-get install -y wget; \
    apt-get install -y uuid-dev

RUN wget https://www.openssl.org/source/old/1.1.1/openssl-1.1.1q.tar.gz; \
    tar xzvf openssl-1.1.1q.tar.gz

RUN cd openssl-1.1.1q; \
    ./config; \
    CORE_NB=$(grep -c ^processor /proc/cpuinfo); \
    make -j$CORE_NB; \
    make install

RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz -O Python-x.y.z.tar.gz; \
    tar -xvf Python-x.y.z.tar.gz

ENV LD_LIBRARY_PATH=/usr/local/lib/

RUN cd Python-*/; \
    ./configure --enable-optimizations --with-lto --disable-test-modules --without-doc-strings --with-computed-gotos --enable-shared --with-system-ffi --enable-loadable-sqlite-extensions --with-ssl-default-suites=openssl --with-openssl=/openssl-1.1.1q/

RUN cd Python-*/; \
    CORE_NB=$(grep -c ^processor /proc/cpuinfo); \
    make PROFILE_TASK="-m test.regrtest --pgo -j$CORE_NB" -j$CORE_NB; \
    make altinstall; \
    /sbin/ldconfig -v; \
    make clean

RUN /usr/bin/wget https://sh.rustup.rs -O rustup.sh;\
    chmod ugo+rwx rustup.sh; \
    ./rustup.sh -y; \
    export PATH=$PATH:/root/.cargo/bin; \
    rm /rustup*

ENV PATH=$PATH:/root/.cargo/bin

RUN wget https://bootstrap.pypa.io/get-pip.py;  \
    python3.11 get-pip.py; \
    rm get-pip.py

# clean src

RUN rm -rf /Python-*
RUN rm -rf /openssl-1.1.1q*
RUN apt-get autoclean -y
RUN apt-get autoremove -y
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
RUN rm -rf /var/lib/apt/lists/*

RUN python3.11 --version

CMD ["python3.11"]
