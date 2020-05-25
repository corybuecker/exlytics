FROM ubuntu:18.04

RUN apt-get update && \
  apt-get install -y --no-install-recommends libssl1.0-dev && \
  rm -rf /var/lib/apt/lists/*

ARG release=_build/dev/rel/dashboard
ENV MIX_HOME /home

WORKDIR /home
COPY $release /home/

CMD ["/home/bin/dashboard", "start"]