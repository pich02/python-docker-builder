FROM pich02/scip-multi-arch:9.0.0 as scip-image
FROM pich02/python3-glibc2.24:3.11.9

COPY --from=scip-image /scip/ /usr/local/

RUN python3.11 -m pip install pyscipopt==5.0.0

CMD ["python3.11"]