FROM pich02/python3-glibc2.24:3.13.5

ARG PIP_EXTRA_INDEX
ENV PIP_EXTRA_INDEX=$PIP_EXTRA_INDEX
ENV GCC_VERSION=9.3.0

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    apt update; \
    apt-get install -y wget g++ m4 xz-utils libgmp-dev unzip zlib1g-dev libboost-program-options-dev libboost-serialization-dev libboost-regex-dev libboost-iostreams-dev libtbb-dev libreadline-dev pkg-config git liblapack-dev libgsl-dev flex bison libcliquer-dev gfortran file dpkg-dev libopenblas-dev rpm

RUN export MAKEFLAGS="-j$(grep -c ^processor /proc/cpuinfo)"; \
    python3.13 -m pip install --no-input --extra-index-url=${PIP_EXTRA_INDEX} ninja

RUN export MAKEFLAGS="-j$(grep -c ^processor /proc/cpuinfo)"; \
    OPENSSL_ROOT_DIR=/openssl-3.2.0/ python3.13 -m pip install --no-input --extra-index-url=${PIP_EXTRA_INDEX} --upgrade cmake

RUN wget https://scipopt.org/download/release/scip-9.1.1.tgz; \
    tar -xvf scip-9.1.1.tgz; \
    cd scip-9.1.1; \
    mkdir build ; \
    cd build; \
    export MAKEFLAGS="-j$(grep -c ^processor /proc/cpuinfo)"; \
    python3.13 -m cmake .. -DPAPILO=off -DZIMPL=off -DIPOPT=off; \
    make -j$(grep -c ^processor /proc/cpuinfo); \
    make install

RUN python3.13 -m pip install --no-input --extra-index-url=${PIP_EXTRA_INDEX} pyscipopt==5.3.0; \
  python3.13 -c "import pyscipopt;"

CMD ["python3.13 -m pip list"]