FROM pich02/python3-glibc2.24:3.13.3

ARG PIP_EXTRA_INDEX
ENV PIP_EXTRA_INDEX=$PIP_EXTRA_INDEX

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    apt update; \
    apt-get install -y wget g++ m4 xz-utils libgmp-dev unzip zlib1g-dev libboost-program-options-dev libboost-serialization-dev libboost-regex-dev libboost-iostreams-dev libtbb-dev libreadline-dev pkg-config git liblapack-dev libgsl-dev flex bison libcliquer-dev gfortran file dpkg-dev libopenblas-dev rpm

RUN export MAKEFLAGS="-j$(grep -c ^processor /proc/cpuinfo)"; \
    python3.13 -m pip install --no-input --extra-index-url=${PIP_EXTRA_INDEX} ninja

RUN export MAKEFLAGS="-j$(grep -c ^processor /proc/cpuinfo)"; \
    OPENSSL_ROOT_DIR=/openssl-3.2.0/ python3.13 -m pip install --no-input --extra-index-url=${PIP_EXTRA_INDEX} --upgrade cmake

RUN wget https://scipopt.org/download/release/scip-9.2.2.tgz; \
    tar -xvf scip-9.2.2.tgz; \
    cd scip-9.2.2; \
    mkdir build ; \
    cd build; \
    export MAKEFLAGS="-j$(grep -c ^processor /proc/cpuinfo)"; \
    python3.13 -m cmake .. -DPAPILO=off -DZIMPL=off -DIPOPT=off; \
    make -j$(grep -c ^processor /proc/cpuinfo); \
    make install

COPY ./builder-gcc-9-1-0.sh /builder-gcc-9-1-0.sh

RUN chmod ugo+wrx builder-gcc-9-1-0.sh; \
    /builder-gcc-9-1-0.sh

RUN export MAKEFLAGS="-j$(grep -c ^processor /proc/cpuinfo)"; \
    export CXX=/root/opt/gcc-9.1.0/bin/g++; \
    export CC=/root/opt/gcc-9.1.0/bin/gcc; \
    export LD=/root/opt/gcc-9.1.0/bin/g++; \
    python3.13 -m pip install --no-input --extra-index-url=${PIP_EXTRA_INDEX} NumPy

RUN python3.13 -m pip install --no-input --extra-index-url=${PIP_EXTRA_INDEX} pyscipopt==5.5.0; \
  python3.13 -c "import pyscipopt;"

CMD ["python3.13 -m pip list"]