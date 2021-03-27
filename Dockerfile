FROM python:3.9.2-alpine

ARG PACKAGES="curl vim git alpine-sdk libtool m4 automake autoconf"
RUN apk --no-cache add $PACKAGES

RUN addgroup -g 5000 exlytics
RUN adduser -h /home/exlytics -G exlytics -u 5000 -D exlytics

COPY --chown=exlytics:exlytics poetry.lock pyproject.toml exlytics/ /home/exlytics
COPY --chown=exlytics:exlytics exlytics /home/exlytics/exlytics

USER exlytics
WORKDIR /home/exlytics
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
ENV PATH="/home/exlytics/.poetry/bin:$PATH"
RUN poetry install

USER root
RUN apk del $PACKAGES
USER exlytics

ENV PORT=5000

CMD ["poetry", "run", "sanic", "--access-logs", "-p", "$PORT", "exlytics.main.app"]