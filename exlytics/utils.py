import os
import sys
import asyncpg  # type: ignore
import sanic
from sanic.log import logger
import json
from typing import Iterator, Tuple, Optional, Any


async def init(con):
    await con.set_type_codec(
        'jsonb', schema='pg_catalog', encoder=json.dumps, decoder=json.loads
    )


async def setup_db(app, loop) -> None:
    try:
        db: asyncpg.Pool = await asyncpg.create_pool(
            database=os.environ['DATABASE_NAME'],
            user=os.environ['DATABASE_USER'],
            password=os.environ['DATABASE_PASSWORD'],
            host=os.environ['DATABASE_HOST'],
            init=init,
        )

        app.config.update({
            'db': db,
        })
    except KeyError as err:
        logger.error(
            "the environment variable {} is missing".format(err.args[0]))
        sys.exit(1)
    finally:
        return None


def extract_recordable_headers(
        request: sanic.request.Request) -> list[tuple[str, str]]:
    allowable_headers = ['host', 'origin', 'referer', 'user-agent']

    headers: Iterator[Tuple[str, str]] = map(
        lambda k: (k, request.headers.getone(k, '')),
        filter(lambda k: k in allowable_headers, request.headers),
    )

    return list(filter(lambda k: k[1] != '', headers))
