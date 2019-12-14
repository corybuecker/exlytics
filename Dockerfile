FROM elixir:1.9-alpine

ENV MIX_ENV prod
ENV MIX_HOME /home

EXPOSE 8080

COPY mix.lock mix.exs ${MIX_HOME}/
WORKDIR ${MIX_HOME}

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix deps.compile

COPY . ${MIX_HOME}

RUN mix compile

CMD ["mix", "run", "--no-halt"]