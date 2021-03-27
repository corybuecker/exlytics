from asyncpg import Pool  # type: ignore
from exlytics.utils import extract_recordable_headers
from sanic import HTTPResponse, Sanic
from sanic.log import logger
from sanic.request import Request
from sanic.response import empty
from sanic.views import HTTPMethodView


class ExlyticsView(HTTPMethodView):
    async def get(self, request: Request) -> HTTPResponse:
        args = request.query_args
        args.extend(extract_recordable_headers(request))

        logger.debug(args)
        app: Sanic = Sanic.get_app()
        database: Pool = app.config.get('db')

        await database.execute('''
            INSERT INTO exlytics.events(time, metadata) VALUES(now(), $1)
        ''', dict(args))
        return empty()

    async def post(self, request: Request) -> HTTPResponse:
        args = request.json
        args.update(extract_recordable_headers(request))

        logger.debug(args)

        app: Sanic = Sanic.get_app()
        database: Pool = app.config.get('db')

        await database.execute('''
            INSERT INTO exlytics.events(time, metadata) VALUES(now(), $1)
        ''', args)

        return empty()
