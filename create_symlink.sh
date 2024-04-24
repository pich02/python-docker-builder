#!/usr/bin/env bash

if [[ ${TARGETARCH} == "amd64" ]]; then
  ARCH="x86_64"
elif [[ ${TARGETARCH} == "arm64"  ]]
 ARCH="arm"
else
  ARCH=${TARGETARCH}
fi

echo "SYMLINK ARCH : $ARCH"

ln -s /usr/local/include/soplex/ /scip-9.0.0/lib/include/spxinc;
ln -s /usr/local/lib/libsoplex.a /scip-9.0.0/lib/static/libsoplex.linux.${ARCH}.gnu.a;
ln -s /usr/local/lib/libsoplex.a /usr/local/lib/libsoplex.linux.${ARCH}.gnu.opt.a;

ldconfig -v;
