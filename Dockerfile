FROM elixir:1.10.4-alpine AS builder
ARG mix_env=dev

ENV MIX_HOME /exlytics
ENV MIX_ENV $mix_env

WORKDIR $MIX_HOME
COPY . $MIX_HOME

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix release

FROM elixir:1.10.4-alpine

ARG release=/exlytics/_build/dev/rel/exlytics

COPY --from=builder $release /exlytics

CMD ["/exlytics/bin/exlytics", "start"]