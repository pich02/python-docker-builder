FROM pich02/scip-multi-arch:9.0.0 as scip-image
FROM pich02/python3-glibc2.24:3.11.9

COPY --from=scip-image /scip/ /usr/local/
COPY --from=scip-image /scip-9.0.0/ /scip-9.0.0/

RUN export SCIPOPTDIR=/scip-9.0.0/; \
    python3.11 -m pip install pyscipopt

CMD ["python3.11"]