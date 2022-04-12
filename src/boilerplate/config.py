# Read configs from .env files and shell environment at the same time.
# Keep development, staging and production configs separate.
# Convert variable types automatically in the appropriate cases, e.g. string to integer conversion.

import errno
import math
import os
from enum import Enum
from ipaddress import IPv4Address
from pathlib import Path
from typing import Optional, Union

from pydantic import (
    BaseModel,
    BaseSettings,
    Field,
    HttpUrl,
    NonNegativeInt,
    PositiveFloat,
    PositiveInt,
    PostgresDsn,
    SecretStr,
    conint,
    constr,
)


def get_path_to_dotenv_file(dotenv_filename: str) -> Path:
    path_to_dotenv_file = Path(__file__).resolve().parents[2].joinpath(dotenv_filename)
    if not path_to_dotenv_file.exists():
        raise FileNotFoundError(
            errno.ENOENT,
            os.strerror(errno.ENOENT),
            str(path_to_dotenv_file),
        )
    return path_to_dotenv_file


class EnvState(str, Enum):
    development = 'development'
    staging = 'staging'
    production = 'production'


class AppInternalLogicConfig(BaseModel):
    """Application internal logic config.

    Class defines the config variables required for API’s internal logic.
    """

    RANDOM_SEED: int = 42


class GlobalConfig(BaseSettings):
    """Global configurations.

    `GlobalConfig` defines the variables that propagate through other environment classes and the attributes of this
    class are globally accessible from all other environments.

    In this class, the variables are loaded from the `.env` file. However, if there is a shell environment variable
    having the same name, that will take precedence.

    The class `GlobalConfig` inherits from Pydantic’s `BaseSettings` which helps to load and read the variables from
    the `.env file`. The `.env` file itself is loaded in the nested `Config` class.

    Although the environment variables are loaded from the `.env` file, Pydantic also loads your actual shell
    environment variables at the same time.

    From Pydantic’s [documentation](https://pydantic-docs.helpmanual.io/usage/settings/):
        ```
        Even when using a `.env` file, `pydantic` will still read environment variables as well as the `.env` file,
        environment variables will always take priority over values loaded from a dotenv file.
        ```
    """

    # General application config.
    _DEFAULT_APP_NAME_VALUE: str = 'boilerplate'
    APP_INTERNAL_LOGIC_CONFIG: AppInternalLogicConfig = AppInternalLogicConfig()
    APP_NAME: str = Field(default=_DEFAULT_APP_NAME_VALUE, const=True, min_length=1)
    APP_ENV_STATE: EnvState = EnvState.development
    APP_ROOT_PATH: str = ''
    APP_API_VERSION: str = Field(default='v1', regex=r'^v\d+$')  # v1, v12, v123
    APP_API_ACCESS_HTTP_BEARER_TOKEN: Optional[SecretStr]
    APP_CI_COMMIT_SHA: str = Field(default='development_commit_sha', min_length=1)  # git commit hash.
    APP_IDEMPOTENCY_KEY_VALIDITY_TIME_SECONDS: PositiveInt = 5 * 60
    APP_HTTP_HEADERS_CONTENT_TYPE_APP_JSON: str = Field(default='application/json', min_length=1)

    # Uvicorn config.
    SERVICE_PROTOCOL: str = Field(default='http', regex=r'^(http|https)$')
    SERVICE_HOST: IPv4Address = IPv4Address('0.0.0.0')
    SERVICE_PORT: int = Field(default=50000, ge=50000, le=60000)

    # Database config.
    DB_DRIVER: str = Field(default='postgresql', min_length=1)
    DB_HOST: str = Field(default='localhost', min_length=1)
    DB_PORT: int = Field(default=5432, ge=0)
    DB_USER: SecretStr = Field(min_length=1)
    DB_PASSWORD: SecretStr = Field(min_length=1)
    DB_DATABASE: str = Field(default='boilerplate', min_length=1)
    DB_SCHEMA: str = Field(default='app_work_data', min_length=1)
    DB_DSN: Optional[PostgresDsn]

    # Sentry config : https://docs.sentry.io/product/sentry-basics/dsn-explainer/
    SENTRY_DSN: Optional[HttpUrl]
    SENTRY_ENVIRONMENT: EnvState = Field(env='APP_ENV_STATE', default=EnvState.development, min_length=1)
    SENTRY_RELEASE: Optional[str] = Field(env='APP_CI_COMMIT_SHA', default='development_release', min_length=1)

    # Elastic APM Python Agent config: https://www.elastic.co/guide/en/apm/agent/python/current/index.html
    ELASTIC_APM_SCHEME: Optional[str] = Field(default='http', regex=r'^(http|https)$')
    ELASTIC_APM_HOST: Optional[str] = Field(min_length=1)
    ELASTIC_APM_PORT: Optional[int] = Field(default=8200, ge=0)

    # Aiohttp config.
    AIOHTTP_SESSION_TIMEOUT_SECONDS: PositiveFloat = 2 * 60.0

    # Tenacity retry config.
    TENACITY_STOP_AFTER_DELAY_SECONDS: PositiveInt = math.ceil(AIOHTTP_SESSION_TIMEOUT_SECONDS)
    TENACITY_STOP_AFTER_ATTEMPT: PositiveInt = 10
    TENACITY_WAIT_FIXED: NonNegativeInt = 5
    TENACITY_WAIT_RANDOM_MIN: NonNegativeInt = 0
    TENACITY_WAIT_RANDOM_MAX: PositiveInt = 5

    # Docker config
    DOCKER_CI_REGISTRY_IMAGE: str = Field(default=_DEFAULT_APP_NAME_VALUE, min_length=1)
    DOCKER_IMAGE_TAG: str = Field(default='latest', min_length=1)
    DOCKER_CI_PROJECT_NAME: str = Field(default=_DEFAULT_APP_NAME_VALUE, min_length=1)

    class Config():
        """Loads the dotenv file.

        Environment variables will always take priority over values loaded from a dotenv file.
        """
        env_file: Path = get_path_to_dotenv_file(dotenv_filename='.env')
        anystr_strip_whitespace = True


class DevelopmentConfig(GlobalConfig):
    """Development configurations.

    `DevelopmentConfig` class inherits from the `GlobalConfig` class, and it can define additional variables
    specific to the development environment. It inherits all the variables defined in the `GlobalConfig` class.
    """

    # Service config.
    IS_DEBUG: bool = True
    APP_IDEMPOTENCY_KEY_VALIDITY_TIME_IN_SECONDS: PositiveInt = 15

    # Database config.
    DB_HOST: constr(min_length=1) = Field(default='localhost')  # type: ignore

    class Config():
        # env_prefix: str = "DEV_"
        anystr_strip_whitespace = True

class StagingConfig(GlobalConfig):
    """Staging configurations.

    `StagingConfig` class also inherits from the `GlobalConfig` class, and it can define additional variables
    specific to the staging environment. It inherits all the variables defined in the `GlobalConfig class`.
    """
    # Application config.
    IS_DEBUG: bool = True

    class Config():
        # env_prefix: str = "STAGING_"
        anystr_strip_whitespace = True


class ProductionConfig(GlobalConfig):
    """Production configurations.

    `ProductionConfig` class also inherits from the `GlobalConfig` class, and it can define additional variables
    specific to the production environment. It inherits all the variables defined in the `GlobalConfig class`.
    """
    IS_DEBUG: bool = False

    class Config():
        # env_prefix: str = "PROD_"
        anystr_strip_whitespace = True


class FactoryConfig:
    """Returns a config instance.

    `FactoryConfig` is the controller class that dictates which config class should be activated based on the
    environment state defined as `SENTRY_ENVIRONMENT`(aka `ENV_STATE`) in the `.env` file.

    If it finds `GlobalConfig().ENV_STATE="development"` then the control flow statements in the `FactoryConfig` class
    will activate the development configs (`DevelopmentConfig`).
    """

    def __init__(self, env_state: EnvState) -> None:
        self.env_state = env_state

    def __call__(self) -> Union[StagingConfig, ProductionConfig, DevelopmentConfig]:
        if self.env_state == EnvState.staging:
            return StagingConfig()
        elif self.env_state == EnvState.production:
            return ProductionConfig()
        elif self.env_state == EnvState.development:
            return DevelopmentConfig()
        else:
            raise ValueError("Incorrect environment variable 'ENV_STATE': %s.", self.env_state)


config = FactoryConfig(env_state=GlobalConfig().APP_ENV_STATE)()


def main() -> None:
    print("FactoryConfig: {factory_config}".format(factory_config=config.json()))
    print(
        "AppInternalLogicConfig: {app_internal_logic_config}".format(
            app_internal_logic_config=config.APP_INTERNAL_LOGIC_CONFIG.json()
        )
    )


if __name__ == '__main__':
    main()
