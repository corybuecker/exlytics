FROM elixir:1.10-alpine

ENV MIX_HOME /home

EXPOSE 80

COPY mix.lock mix.exs ${MIX_HOME}/
WORKDIR ${MIX_HOME}

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

RUN MIX_ENV=prod mix deps.compile
RUN MIX_ENV=integration mix deps.compile

COPY . ${MIX_HOME}

RUN MIX_ENV=prod mix compile
RUN MIX_ENV=integration mix compile

CMD ["mix", "run", "--no-halt"]