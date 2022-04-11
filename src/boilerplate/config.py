# Read configs from .env files and shell environment at the same time.
# Keep development, staging and production configs separate.
# Convert variable types automatically in the appropriate cases, e.g. string to integer conversion.

import errno
import math
import os
from enum import Enum
from ipaddress import IPv4Address
from typing import Optional, Union, Final
from pathlib import Path

from pydantic import (
    BaseModel,
    BaseSettings,
    Field,
    HttpUrl,
    NonNegativeInt,
    PositiveFloat,
    PositiveInt,
    PostgresDsn,
    constr,
    SecretStr, conint,
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
    APP_INTERNAL_LOGIC_CONFIG: AppInternalLogicConfig = AppInternalLogicConfig()
    APP_NAME: constr(min_length=1) = Field(default='boilerplate', const=True)
    APP_ENV_STATE: EnvState = EnvState.development
    APP_ROOT_PATH: Optional[constr()] = ""
    APP_API_VERSION: constr(regex=r'^v\d+$') = 'v1'  # type: ignore # v1, v12, v123
    APP_API_ACCESS_HTTP_BEARER_TOKEN: Optional[SecretStr]
    APP_CI_COMMIT_SHA: constr(min_length=1) = "development_ci_commit_sha"  # git commit hash.
    APP_IDEMPOTENCY_KEY_VALIDITY_TIME_IN_SECONDS: PositiveInt = 5 * 60

    # Uvicorn config.
    SERVICE_PROTOCOL: constr(regex=r'^(http|https)$') = 'http'  # type: ignore
    SERVICE_HOST: IPv4Address = '0.0.0.0'
    SERVICE_PORT: conint(ge=50000, le=60000) = 50000

    # Database config.
    DB_DRIVER: Optional[constr(min_length=1)] = 'postgresql'
    DB_HOST: Optional[constr(min_length=1)] = 'localhost'
    DB_PORT: Optional[conint(ge=0)] = 5432
    DB_USER: Optional[SecretStr]
    DB_PASSWORD: Optional[SecretStr]
    DB_DATABASE: Optional[constr(min_length=1)] = APP_NAME
    DB_SCHEMA: Optional[constr(min_length=1)] = "app_work_data"
    DB_DSN: Optional[PostgresDsn]

    # Sentry config : https://docs.sentry.io/product/sentry-basics/dsn-explainer/
    SENTRY_DSN: Optional[HttpUrl]
    SENTRY_RELEASE: Optional[constr(min_length=1)] = Field(
        env="APP_CI_COMMIT_SHA",
        default=os.environ.get("SENTRY_RELEASE", default="development_release_00")
    )
    SENTRY_ENVIRONMENT: EnvState = Field(env="ENV_STATE")

    # Elastic APM Python Agent config: https://www.elastic.co/guide/en/apm/agent/python/current/index.html.
    ELASTIC_APM_SCHEME: Optional[constr(regex=r'^(http|https)$')]
    ELASTIC_APM_HOST: Optional[constr(min_length=1)]
    ELASTIC_APM_PORT: Optional[conint(ge=0)]

    # Aiohttp config.
    HTTP_HEADERS_CONTENT_TYPE_APP_JSON: constr(min_length=1) = 'application/json'
    AIOHTTP_SESSION_TIMEOUT_SEC: PositiveFloat = 2 * 60.0

    # Tenacity retry config.
    TENACITY_STOP_AFTER_DELAY_SECONDS: PositiveInt = math.ceil(AIOHTTP_SESSION_TIMEOUT_SEC)
    TENACITY_STOP_AFTER_ATTEMPT: PositiveInt = 10
    TENACITY_WAIT_FIXED: NonNegativeInt = 5
    TENACITY_WAIT_RANDOM_MIN: NonNegativeInt = 0
    TENACITY_WAIT_RANDOM_MAX: PositiveInt = 5

    # Docker config
    DOCKER_CI_REGISTRY_IMAGE: constr(min_length=1) = APP_NAME
    DOCKER_IMAGE_TAG: constr(min_length=1) = 'latest'
    DOCKER_CI_PROJECT_NAME: constr(min_length=1) = APP_NAME

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
