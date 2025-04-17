FROM pich02/python3-glibc2.24:3.13.3

RUN python3.11 -m pip install pyscipopt==5.1.1;

CMD ["python3.11 -m pip list"]