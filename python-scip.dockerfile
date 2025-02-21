FROM pich02/scip-multi-arch:9.2.0 as scip-image
FROM pich02/python3-glibc2.24:3.11.11

COPY --from=scip-image /scip-install /scip-install

RUN export SCIPOPTDIR=/scip-install; \
    python3.11 -m pip install pyscipopt==5.2.1

CMD ["python3.11 -m pip list"]