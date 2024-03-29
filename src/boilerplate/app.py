# ########################################################################################
#  Copyright (c) 2022 Viacheslav Kolupaev; author's website address:
#
#      https://vkolupaev.com/?utm_source=c&utm_medium=link&utm_campaign=notebook
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# ########################################################################################

"""FastAPI application initialization module."""
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.openapi.docs import get_swagger_ui_html
from fastapi.responses import FileResponse, HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from sentry_sdk.integrations.asgi import SentryAsgiMiddleware

from src.boilerplate.config import config
from src.boilerplate.custom_logger import CustomLogger
from src.boilerplate.routers import admin_controller
from src.boilerplate.sentry import init_sentry

_module_logger = CustomLogger().get_module_logger(
    name=__name__,
    module_extra=None,  # optional data that will be added to each message of this logger
)

tags_metadata = [
    {
        'name': 'admin-controller',
        'description':
            (
                'Administrative operations. To access endpoints, use `Bearer` token authorization. ' +
                'You can get a token from a DevOps engineer.'
            ),
    },
]

_module_logger.debug('Initializing the FastAPI application...')

app_description = f"""
## 🚀 Release

Current `APP_VCS_REF` (commit) SHA: **{config.APP_VCS_REF}**

## ⚙️ Base URLs

Staging: [https://vkolupaev.com/](https://vkolupaev.com/)

Production: [https://vkolupaev.com/](https://vkolupaev.com/)

## Resources for QA-engineers

Confluence page: [https://vkolupaev.com/](https://vkolupaev.com/)

## Jira

This project's task board: [https://vkolupaev.com/](https://vkolupaev.com/)

## Idempotency

In the context of an API, *idempotency* means that multiple requests are handled in the same way as single requests.
This means that upon receiving a second request with the same parameters, the API will return the result of the
original request in response.

`GET`-requests are idempotent by default, since they have no unwanted consequences. To ensure the idempotency of
`POST`-requests, the `idempotency-key` header is used.

If you repeat a request with the same data and the same key, the API treats it as a repeat request.
If the data in the request is the same, but the idempotency key is different, the request is
executed as new.

The API provides idempotency for **{config.APP_IDEMPOTENCY_KEY_VALIDITY_TIME_SECONDS} seconds** after the first
request, then a repeated request will be processed as a new one.

## ⏲️ Time contract

* To process tasks, the application requests internal and external services. The response time is not guaranteed.
* The application seeks to provide the client with a response within **5 (five) minutes after** receiving the
request (creating a task).
* If the application does not meet this limit, the **client SHOULD** stop waiting and apply the fallback logic.

## 👨‍🔧 Maintainer

"""

app = FastAPI(
    title=config.APP_NAME,
    description=app_description,
    version=config.APP_API_VERSION,
    openapi_tags=tags_metadata,
    docs_url=None,
    redoc_url=None,
    contact={
        'name': 'Viacheslav Kolupaev',
        'url': 'https://vkolupaev.com/',
        'email': 'enter-email-if-needed',
    },
    license_info={
        'name': 'Apache 2.0',
        'url': 'https://www.apache.org/licenses/LICENSE-2.0',
    },
)

# Static Files: https://fastapi.tiangolo.com/tutorial/static-files/
static_dir_path = Path(__file__).parent.absolute().joinpath('static')
app.mount(path='/static', app=StaticFiles(directory=static_dir_path), name='static')

_module_logger.debug('Initializing Routers...')
app.include_router(admin_controller.router)


@app.on_event('startup')
async def startup() -> None:
    """Execute application startup operations."""
    _module_logger.debug('Executing startup operations...')

    _module_logger.debug('Initializing Middleware...')

    minimum_size_in_bytes_for_gzip_compression = 150
    app.add_middleware(GZipMiddleware, minimum_size=minimum_size_in_bytes_for_gzip_compression)

    app.add_middleware(SentryAsgiMiddleware)

    _module_logger.debug('Initializing Sentry...')
    init_sentry()

    _module_logger.debug('Startup operations completed.')


@app.on_event('shutdown')
async def shutdown() -> None:
    """Execute application shutdown operations."""
    _module_logger.debug('Executing operations operations...')

    _module_logger.debug('Shutdown operations completed.')


@app.get(
    path='/',
    include_in_schema=False,
)
async def root() -> RedirectResponse:
    """API root endpoint."""
    return RedirectResponse('/docs')


@app.get(
    path='/favicon.ico',
    include_in_schema=True,
    response_class=FileResponse,
)
async def favicon() -> FileResponse:
    """Get `favicon.ico`."""
    return FileResponse(
        path=Path(static_dir_path).absolute().joinpath('favicon.ico'),
        media_type='image/x-icon',
        filename='favicon.ico',
    )


@app.get(
    path='/docs',
    include_in_schema=False,
)
async def swagger_ui_html(req: Request) -> HTMLResponse:
    """Get custom Swagger UI HTML."""
    root_path = req.scope.get('root_path', '').rstrip('/')
    openapi_url = root_path + app.openapi_url
    oauth2_redirect_url = app.swagger_ui_oauth2_redirect_url
    if oauth2_redirect_url:
        oauth2_redirect_url = root_path + oauth2_redirect_url

    return get_swagger_ui_html(
        openapi_url=openapi_url,
        title='{app_title} - Swagger UI'.format(app_title=app.title),
        oauth2_redirect_url=oauth2_redirect_url,
        init_oauth=app.swagger_ui_init_oauth,
        swagger_favicon_url='/static/favicon.ico',
        swagger_ui_parameters=app.swagger_ui_parameters,
    )
