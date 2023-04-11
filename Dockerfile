# Alpine based stockfish container
# https://github.com/official-stockfish/Stockfish

FROM python:buster

LABEL maintainer "Robert Title <rtitle@broadinstitute.org>"

ENV SOURCE_REPO https://github.com/official-stockfish/Stockfish
ENV VERSION master

ADD ${SOURCE_REPO}/archive/${VERSION}.tar.gz /root
WORKDIR /root

RUN if [ ! -d Stockfish-${VERSION} ]; then tar xvzf *.tar.gz; fi \
 && cd Stockfish-${VERSION}/src \
 && make build ARCH=x86-64-modern \
 && make install \
 && cd ../.. && rm -rf Stockfish-${VERSION} *.tar.gz

RUN pip install chess

COPY ./src/eval.py /root

ENTRYPOINT [ "python", "eval.py" ]