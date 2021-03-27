from exlytics.utils import setup_db
from exlytics.view import ExlyticsView
from sanic import Sanic
from sanic.response import empty

app = Sanic('exlytics')
app.register_listener(setup_db, "before_server_start")

app.add_route(ExlyticsView.as_view(), "/")


@app.get("/healthcheck")
async def healthcheck(request):
    return empty()


app.run(host='0.0.0.0', port=5000, debug=True)
