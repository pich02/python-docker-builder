FROM pich02/python3-glibc2.24:3.11.9

ENV OPENSSL_DIR=/openssl320
ENV OPENSSL_VERSION=3.2.0

RUN curl -O https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz; \
    rm -rf /openssl-3.2.0/; \
    tar xvf openssl-${OPENSSL_VERSION}.tar.gz

RUN cd /openssl-3.2.0; \
    ./config no-shared no-ssl2 no-ssl3 -fPIC --prefix=/openssl320 no-docs; \
    make -j$(grep -c ^processor /proc/cpuinfo); \
    make install

RUN python3.11 -m pip wheel cryptography==42.0.5 --no-binary cryptography

RUN rm -rf openssl320; \
    rm openssl-${OPENSSL_VERSION}.tar.gz

CMD ["python3.11"]