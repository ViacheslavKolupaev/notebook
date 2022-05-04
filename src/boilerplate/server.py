#  Copyright (c) 2022. Viacheslav Kolupaev, https://vkolupaev.com/
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       https://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

import uvicorn
from app import app
from config import config
from custom_logger import get_logger
from schemas.common import EnvState

_logger = get_logger(logger_name=__name__)


def run_server() -> None:
    """Start the Uvicorn server.

    Attention:
    1. The filename `server.py` is used in the Dockerfile.
    2. In `server: app`: `server` is the name of this module, `app` is the name of the
       imported FastAPI application.
    """
    _logger.debug('Starting the Uvicorn server...')

    app = 'server:app'

    if config.APP_ENV_STATE == EnvState.development:
        uvicorn.run(
            app=app,
            host=config.ASGI_HOST.exploded,
            port=config.ASGI_PORT,
            debug=config.IS_DEBUG,
            reload=True,
        )
    elif config.APP_ENV_STATE == EnvState.staging:
        uvicorn.run(
            app=app,
            host=config.ASGI_HOST.exploded,
            port=config.ASGI_PORT,
            debug=config.IS_DEBUG,
            reload=False,
        )
    elif config.APP_ENV_STATE == EnvState.production:
        uvicorn.run(
            app=app,
            host=config.ASGI_HOST.exploded,
            port=config.ASGI_PORT,
            debug=config.IS_DEBUG,
            reload=False,
        )
    else:
        raise ValueError("Incorrect environment variable 'ENV_STATE': %s.", config.APP_ENV_STATE)


if __name__ == '__main__':
    run_server()
