#!/usr/bin/env bash

TARGETARCH=$1

if [[ ${TARGETARCH} == "amd64" ]]; then
  ARCH="x86_64"
elif [[ ${TARGETARCH} == "arm64"  ]]; then
 ARCH="arm"
else
  ARCH=${TARGETARCH}
fi

echo "SYMLINK ARCH : $ARCH"

ln -s /usr/local/include/soplex/ /scip/lib/include/spxinc;
ln -s /usr/local/lib/libsoplex.a /scip/lib/static/libsoplex.linux.${ARCH}.gnu.a;
ln -s /usr/local/lib/libsoplex.a /usr/local/lib/libsoplex.linux.${ARCH}.gnu.opt.a;

/usr/sbin/ldconfig -v;
