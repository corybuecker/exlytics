FROM elixir:1.15.0-alpine AS builder
ARG mix_env=production

ENV MIX_HOME /exlytics
ENV MIX_ENV $mix_env

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR $MIX_HOME
COPY mix.exs mix.lock $MIX_HOME

RUN mix deps.get
RUN mix deps.compile

COPY . $MIX_HOME
RUN mix release

FROM elixir:1.15.0-alpine
ARG release=/exlytics/_build/production/rel/exlytics

COPY --from=builder $release /home/exlytics

RUN addgroup -g 5000 exlytics && \
  adduser -u 5000 -G exlytics -s /bin/sh -D exlytics && \
  chown -R exlytics:exlytics /home/exlytics

USER exlytics

CMD ["/home/exlytics/bin/exlytics", "start"]
