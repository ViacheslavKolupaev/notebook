import errno
import math
import os
from enum import Enum
from ipaddress import IPv4Address
from typing import Optional, Union
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


class AppConfig(BaseModel):
    """Application configurations.

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
    # Create an Application Configuration Instance
    APP_CONFIG: AppConfig = AppConfig()

    # Service config.
    ENV_STATE: EnvState = Field(env="SENTRY_ENVIRONMENT")
    SERVICE_NAME: str = 'boilerplate'
    ROOT_PATH: Optional[str] = ""
    API_VERSION: constr(regex=r'^v\d+$') = 'v1'  # type: ignore # v1, v12, v123
    IDEMPOTENCY_KEY_VALIDITY_TIME_IN_SECONDS: PositiveInt = 5 * 60
    IS_DEBUG: bool = Field(default=False)
    CI_COMMIT_SHA: str = Field(default=None)  # git commit hash.

    # Uvicorn config.
    SERVICE_PROTOCOL: constr(regex=r'^(http|https)$') = Field(default='http')  # type: ignore # http, https
    SERVICE_HOST: IPv4Address = Field(default='0.0.0.0')
    SERVICE_PORT: PositiveInt = Field(default=50001)

    # Security config.
    API_ACCESS_HTTP_BEARER_TOKEN: constr(min_length=1) = Field(default=None)

    # Database config.
    DB_DRIVER: str = Field(default='postgresql')
    DB_HOST: str = Field(default=None)
    DB_PORT: int = Field(default=None)
    DB_USER: str = Field(default=None)
    DB_PASSWORD: str = Field(default=None)
    DB_DATABASE: str = Field(default=None)
    DB_SCHEMA: Optional[str] = Field(default=None)
    DB_DSN: Optional[PostgresDsn] = Field(default=None)

    # Sentry config.
    SENTRY_DSN: HttpUrl
    SENTRY_ENVIRONMENT: EnvState
    SENTRY_RELEASE: str = Field(
        env="CI_COMMIT_SHA",
        default=os.environ.get("SENTRY_RELEASE", default="development_release_01")
    )

    # Elastic APM config.
    APM_PORT: int = Field(default=8200)
    APM_HOST: constr(min_length=1) = "enter-a-valid-host-address"
    APM_SCHEME: constr(regex=r'^(http|https)$') = Field(default="http")

    # Aiohttp config.
    AIOHTTP_SESSION_TIMEOUT_SEC: PositiveFloat = 2 * 60.0
    HTTP_HEADERS_CONTENT_TYPE_APP_JSON: str = 'application/json'

    # Tenacity retry config.
    STOP_AFTER_DELAY_SECONDS: PositiveInt = math.ceil(AIOHTTP_SESSION_TIMEOUT_SEC)
    STOP_AFTER_ATTEMPT: PositiveInt = 10
    WAIT_FIXED: NonNegativeInt = 5
    WAIT_RANDOM_MIN: NonNegativeInt = 0
    WAIT_RANDOM_MAX: PositiveInt = 5

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
    IDEMPOTENCY_KEY_VALIDITY_TIME_IN_SECONDS: PositiveInt = 30
    IS_DEBUG: bool = Field(default=True)

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
    IS_DEBUG: bool = Field(default=True)

    class Config():
        # env_prefix: str = "STAGING_"
        anystr_strip_whitespace = True


class ProductionConfig(GlobalConfig):
    """Production configurations.

    `ProductionConfig` class also inherits from the `GlobalConfig` class, and it can define additional variables
    specific to the production environment. It inherits all the variables defined in the `GlobalConfig class`.
    """

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


config = FactoryConfig(env_state=GlobalConfig().ENV_STATE)()


def main() -> None:
    print("FactoryConfig: {factory_config}".format(factory_config=config.json()))
    print("AppConfig: {app_config}".format(app_config=config.APP_CONFIG.json()))


if __name__ == '__main__':
    main()
