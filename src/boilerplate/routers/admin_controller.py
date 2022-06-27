# ########################################################################################
#  Copyright (c) 2022. Viacheslav Kolupaev, https://vkolupaev.com/
#
#  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
#  file except in compliance with the License. You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software distributed under
#  the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied. See the License for the specific language governing
#  permissions and limitations under the License.
# ########################################################################################

"""FastAPI admin router module.

This router is used to create service endpoints. It is recommended to restrict free access
to them.
"""

from typing import Union

from fastapi import APIRouter, Depends, status

from src.boilerplate.config import DevelopmentConfig, ProductionConfig, StagingConfig, config
from src.boilerplate.custom_logger import CustomLogger
from src.boilerplate.dependencies import is_media_type_application_json, is_request_has_correct_http_bearer_token
from src.boilerplate.schemas.common import MetadataOpt  # type: ignore[import]

_module_logger = CustomLogger().get_module_logger(
    name=__name__,
    module_extra=None,  # optional data that will be added to each message of this logger
)

router = APIRouter(
    prefix=f"/api/{config.APP_API_VERSION}/admin",
    tags=['admin-controller'],
    responses={
        status.HTTP_401_UNAUTHORIZED: {'description': 'Unauthorized'},
        status.HTTP_403_FORBIDDEN: {'description': 'Forbidden'},
        status.HTTP_404_NOT_FOUND: {'description': 'Not found'},
        status.HTTP_415_UNSUPPORTED_MEDIA_TYPE: {
            'description': 'Unsupported MIME type in header `Accept` or not provided'
        },
    },
    dependencies=[
        Depends(is_request_has_correct_http_bearer_token),
        Depends(is_media_type_application_json),
    ],
)


@router.get(
    path="/app-config",
    response_model=Union[StagingConfig, ProductionConfig, DevelopmentConfig],
    status_code=status.HTTP_200_OK,
    responses={
        status.HTTP_200_OK: {
            'description': 'Requested data returned.',
            'model': Union[StagingConfig, ProductionConfig, DevelopmentConfig],
        },
    },
    summary="Get the application config depending on the environment."
)
async def get_app_config() -> Union[StagingConfig, ProductionConfig, DevelopmentConfig]:
    """Get the application config.

    Depending on the environment, the method will return one of the following models:
    1. `DevelopmentConfig`;
    2. `StagingConfig`;
    3. `ProductionConfig`.

    Fields of type `pydantic.SecretStr` are by default excluded from the description of the model in `Swagger` and
    masked in responses, like this: `"DB_PASSWORD": "**********"`.
    """
    return config

@router.get("/check-sentry")
async def send_event_division_by_zero():
    try:
        1 / 0
    except ZeroDivisionError as e:
        _module_logger.exception("ZeroDivisionError occurred: '%s'.", e)  # will mark the exception

    return {"message": "An error message has been sent to Sentry."}


@router.get("/check-http-bearer-auth")
async def check_http_bearer_auth():
    return {"HTTP Bearer Auth": "OK"}
