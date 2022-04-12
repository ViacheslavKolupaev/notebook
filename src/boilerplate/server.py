import uvicorn

from app import app
from config import config
from schemas.common import EnvState
from custom_logger import get_logger

_logger = get_logger(logger_name=__name__)


def run_server() -> None:
    """Start the Uvicorn server.

    Attention:
    1. The filename 'server.py' is used in the Dockerfile.
    2. In 'server: app': main is the name of this file, app is the name of the imported FastAPI application.

    :return: None
    """
    _logger.debug('Starting the Uvicorn server...')

    app = 'server:app'

    if config.APP_ENV_STATE == EnvState.development:
        uvicorn.run(
            app=app,
            host=str(config.SERVICE_HOST),
            port=config.SERVICE_PORT,
            debug=config.IS_DEBUG,
            reload=True
        )
    elif config.APP_ENV_STATE == EnvState.staging:
        uvicorn.run(
            app=app,
            host=str(config.SERVICE_HOST),
            port=config.SERVICE_PORT,
            debug=config.IS_DEBUG,
            root_path=config.APP_ROOT_PATH
        )
    elif config.APP_ENV_STATE == EnvState.production:
        uvicorn.run(
            app=app,
            host=str(config.SERVICE_HOST),
            port=config.SERVICE_PORT,
            debug=config.IS_DEBUG
        )
    else:
        raise ValueError("Incorrect environment variable 'ENV_STATE': %s.", config.APP_ENV_STATE)


if __name__ == '__main__':
    run_server()
