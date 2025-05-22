FROM pich02/python3-glibc2.24:3.13.3

ENV OPENSSL_DIR=/openssl320
ENV OPENSSL_VERSION=3.2.0

RUN wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz; \
    rm -rf /openssl-3.2.0/; \
    tar xvf openssl-${OPENSSL_VERSION}.tar.gz

RUN cd /openssl-3.2.0; \
    ./config no-shared no-ssl2 no-ssl3 -fPIC --prefix=${OPENSSL_DIR} no-docs; \
    make -j$(grep -c ^processor /proc/cpuinfo); \
    make install

RUN export MAKEFLAGS="-j$(grep -c ^processor /proc/cpuinfo)"; \
    python3.13 -m pip install ninja; \
    python3.13 -m pip install --upgrade cmake

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    apt update; \
    apt-get install -y wget cmake g++ m4 xz-utils libgmp-dev unzip zlib1g-dev libboost-program-options-dev libboost-serialization-dev libboost-regex-dev libboost-iostreams-dev libtbb-dev libreadline-dev pkg-config git liblapack-dev libgsl-dev flex bison libcliquer-dev gfortran file dpkg-dev libopenblas-dev rpm

RUN wget https://scipopt.org/download/release/scip-9.2.2.tgz; \
    tar -xvf scip-9.2.2.tgz; \
    cd scip-9.2.2; \
    mkdir build ; \
    cd build; \
    export MAKEFLAGS="-j$(grep -c ^processor /proc/cpuinfo)"; \
    python3.13 -m cmake .. -DPAPILO=off -DZIMPL=off -DIPOPT=off; \
    make -j$(grep -c ^processor /proc/cpuinfo); \
    make install

RUN python3.13 -m pip install pyscipopt==5.5.0; \
  python3.13 -c "import pyscipopt;"

CMD ["python3.13 -m pip list"]