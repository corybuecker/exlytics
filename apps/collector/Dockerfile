FROM ubuntu:18.04

RUN apt-get update && apt-get install -y libssl1.0-dev

ARG release=_build/dev/rel/collector
ENV MIX_HOME /home

WORKDIR /home
COPY $release /home/

CMD ["/home/bin/collector", "start"]