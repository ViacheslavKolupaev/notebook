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

"""Application config.

Features of the module:
  1. Read configs from `.env` files and shell environment at the same time.
  2. Keep `development`, `staging` and `production` configs separate.
  3. Convert variable types automatically in the appropriate cases,
     e.g. string to integer conversion.

Use the `AppInternalLogicConfig` class to parameterize the application's internal logic.
Getting access to configs from Python code:

```python
from config import config
print(config.RANDOM_SEED)
```

Changing the `GlobalConfig`, `DevelopmentConfig`, `StagingConfig` and `ProductionConfig`
classes must be done in conjunction with DevOps engineers responsible for the CI/CD of
our team and this project in particular: `Bitbucket`, `Jenkins`, `GitLab`, etc.

The module was developed using [Pydantic Settings management](
https://pydantic-docs.helpmanual.io/usage/settings/).
"""

import errno
import math
import os
from ipaddress import IPv4Address
from pathlib import Path
from typing import Optional, Union

import pydantic

from src.boilerplate.schemas.common import EnvState  # type: ignore[import]


def _get_path_to_dotenv_file(dotenv_filename: str, num_of_parent_dirs_up: int) -> Path:
    """Get the path to the `.env` file.

    This is a helper function.
    The path is calculated relative to the location of this module.
    """
    path_to_dotenv_file = Path(__file__).resolve().parents[num_of_parent_dirs_up].joinpath(dotenv_filename)

    if not path_to_dotenv_file.exists():
        raise FileNotFoundError(
            errno.ENOENT,
            os.strerror(errno.ENOENT),
            str(path_to_dotenv_file),
        )
    return path_to_dotenv_file


class AppInternalLogicConfig(pydantic.BaseModel):
    """Application internal logic config.

    Use this class to parameterize application logic.
    """

    RANDOM_SEED: int = 42


class GlobalConfig(pydantic.BaseSettings, AppInternalLogicConfig):
    """Global configurations.

    `GlobalConfig` defines the variables that propagate through other environment classes
    and the attributes of this class are globally accessible from all other environments.

    In this class, the variables are loaded from the `.env` file. However, if there is a
    shell environment variable having the same name, that will take precedence.

    The class `GlobalConfig` inherits from Pydantic’s `BaseSettings` which helps to load
    and read the variables from the `.env file`. The `.env` file itself is loaded in
    the nested `Config` class.

    Although the environment variables are loaded from the `.env` file, Pydantic also
    loads your actual shell environment variables at the same time.

    From Pydantic’s [documentation](https://pydantic-docs.helpmanual.io/usage/settings/):

    ```text
    Even when using a `.env` file, `pydantic` will still read environment variables
    as well as the `.env` file, environment variables will always take priority over
    values loaded from a dotenv file.
    ```
    """

    # General application config.
    _DEFAULT_APP_NAME_VALUE: str = 'boilerplate'

    APP_NAME: str = pydantic.Field(default=_DEFAULT_APP_NAME_VALUE, const=True, min_length=1)
    APP_ENV_STATE: EnvState = EnvState.development
    APP_ROOT_PATH: str = ''
    APP_API_VERSION: str = pydantic.Field(default='v1', regex=r'^v\d+$')  # v1, v12, v123
    APP_API_ACCESS_HTTP_BEARER_TOKEN: Optional[pydantic.SecretStr]
    APP_CI_COMMIT_SHA: str = pydantic.Field(default='development_commit_sha', min_length=1)  # git commit hash.
    APP_IDEMPOTENCY_KEY_VALIDITY_TIME_SECONDS: pydantic.PositiveInt = 5 * 60
    APP_HTTP_HEADERS_CONTENT_TYPE_JSON: str = pydantic.Field(default='application/json', min_length=1)

    # Uvicorn config.
    ASGI_PROTOCOL: str = pydantic.Field(default='http', regex='^(http|https)$')
    ASGI_HOST: IPv4Address = IPv4Address('127.0.0.1')
    ASGI_PORT: int = pydantic.Field(default=50000, ge=50000, le=60000)

    # Database config.
    DB_DRIVER: str = pydantic.Field(default='postgresql', min_length=1)
    DB_HOST: str = pydantic.Field(default='localhost', min_length=1)
    DB_PORT: int = pydantic.Field(default=5432, ge=0)
    DB_USER: pydantic.SecretStr = pydantic.Field(min_length=1)
    DB_PASSWORD: pydantic.SecretStr = pydantic.Field(min_length=1)
    DB_DATABASE: str = pydantic.Field(default='boilerplate', min_length=1)
    DB_SCHEMA: str = pydantic.Field(default='app_work_data', min_length=1)
    DB_DSN: Optional[pydantic.PostgresDsn]

    # Sentry config : https://docs.sentry.io/product/sentry-basics/dsn-explainer/
    SENTRY_DSN: Optional[pydantic.HttpUrl]
    SENTRY_ENVIRONMENT: EnvState = pydantic.Field(env='APP_ENV_STATE', default=EnvState.development, min_length=1)
    SENTRY_RELEASE: Optional[str] = pydantic.Field(env='APP_CI_COMMIT_SHA', default='development_release', min_length=1)

    # Elastic APM Python Agent config: https://www.elastic.co/guide/en/apm/agent/python/current/index.html
    ELASTIC_APM_SCHEME: Optional[str] = pydantic.Field(default='http', regex='^(http|https)$')
    ELASTIC_APM_HOST: Optional[str] = pydantic.Field(min_length=1)
    ELASTIC_APM_PORT: Optional[int] = pydantic.Field(default=8200, ge=0)

    # Aiohttp config.
    AIOHTTP_SESSION_TIMEOUT_SECONDS: pydantic.PositiveFloat = 2 * 60.0

    # Tenacity retry config.
    TENACITY_STOP_AFTER_DELAY_SECONDS: pydantic.PositiveInt = math.ceil(AIOHTTP_SESSION_TIMEOUT_SECONDS)
    TENACITY_STOP_AFTER_ATTEMPT: pydantic.PositiveInt = 10
    TENACITY_WAIT_FIXED: pydantic.NonNegativeInt = 5
    TENACITY_WAIT_RANDOM_MIN: pydantic.NonNegativeInt = 0
    TENACITY_WAIT_RANDOM_MAX: pydantic.PositiveInt = 5

    # Docker config
    DOCKER_CI_REGISTRY_IMAGE: str = pydantic.Field(default=_DEFAULT_APP_NAME_VALUE, min_length=1)
    DOCKER_IMAGE_TAG: str = pydantic.Field(default='latest', min_length=1)
    DOCKER_CI_PROJECT_NAME: str = pydantic.Field(default=_DEFAULT_APP_NAME_VALUE, min_length=1)

    class Config(object):
        """Pydantic Model Config.

        Loads the dotenv file. Environment variables will always take priority over values
        loaded from a dotenv file.
        """

        env_file: Path = _get_path_to_dotenv_file(dotenv_filename='.env', num_of_parent_dirs_up=2)
        anystr_strip_whitespace = True


class DevelopmentConfig(GlobalConfig):
    """Development configurations.

    `DevelopmentConfig` class inherits from the `GlobalConfig` class, and it can define
    additional variables specific to the development environment. It inherits all the
    variables defined in the `GlobalConfig` class.
    """

    # Defining new attributes that are not in the `GlobalConfig` class.
    IS_DEBUG: bool = True

    # Redefining attributes defined earlier in the `GlobalConfig` class.
    APP_IDEMPOTENCY_KEY_VALIDITY_TIME_SECONDS: pydantic.PositiveInt = 15
    DB_HOST: str = pydantic.Field(default='localhost', min_length=1)

    class Config(object):
        """Pydantic Model Config."""

        anystr_strip_whitespace = True


class StagingConfig(GlobalConfig):
    """Staging configurations.

    `StagingConfig` class also inherits from the `GlobalConfig` class, and it can define
    additional variables specific to the staging environment. It inherits all the
    variables defined in the `GlobalConfig class`.
    """

    # Defining new attributes that are not in the `GlobalConfig` class.
    IS_DEBUG: bool = True

    class Config(object):
        """Pydantic Model Config."""

        anystr_strip_whitespace = True


class ProductionConfig(GlobalConfig):
    """Production configurations.

    `ProductionConfig` class also inherits from the `GlobalConfig` class, and it can
    define additional variables specific to the production environment. It inherits all
    the variables defined in the `GlobalConfig class`.
    """

    # Defining new attributes that are not in the `GlobalConfig` class.
    IS_DEBUG: bool = False

    class Config(object):
        """Pydantic Model Config."""

        anystr_strip_whitespace = True


class FactoryConfig(object):
    """Returns a config instance.

    `FactoryConfig` is the controller class that dictates which config class should be
    activated based on the environment state defined as `APP_ENV_STATE` in the `.env` file.

    If it finds `GlobalConfig().APP_ENV_STATE="development"` then the control flow
    statements in the `FactoryConfig` class will activate the development configs —
    `DevelopmentConfig`.
    """

    def __init__(self, app_env_state: EnvState) -> None:
        """Customize the class instance immediately after its creation."""
        self.app_env_state = app_env_state

    def __call__(self) -> Union[StagingConfig, ProductionConfig, DevelopmentConfig]:
        """Get the application config depending on the environment."""
        if self.app_env_state == EnvState.staging:
            return StagingConfig()
        elif self.app_env_state == EnvState.production:
            return ProductionConfig()
        elif self.app_env_state == EnvState.development:
            return DevelopmentConfig()
        raise ValueError(
            "Incorrect environment variable 'APP_ENV_STATE': {app_env_state}.".
            format(app_env_state=self.app_env_state),
        )


config = FactoryConfig(app_env_state=GlobalConfig().APP_ENV_STATE)()
