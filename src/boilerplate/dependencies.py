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

import secrets

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from src.boilerplate.config import config

security = HTTPBearer()

async def is_request_has_correct_http_bearer_token(
    authorization: HTTPAuthorizationCredentials = Depends(security)
) -> None:
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail='No access to resource. HTTP Bearer Token is missing!',
            headers={
                "WWW-Authenticate": f"Bearer realm=\"{config.APP_NAME}/api/{config.APP_API_VERSION}/ \", "
                                    f"charset=\"UTF-8\""
            }
        )

    is_correct_token = secrets.compare_digest(
        authorization.credentials,
        config.APP_API_ACCESS_HTTP_BEARER_TOKEN.get_secret_value(),
    )

    if not is_correct_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail='No access to resource. Invalid HTTP Bearer Token!',
            headers={
                # RFC 2617: https://datatracker.ietf.org/doc/html/rfc2617#section-3.2.1
                "WWW-Authenticate": f"Bearer realm=\"{config.APP_NAME}/api/{config.APP_API_VERSION}/ \", "
                                    f"charset=\"UTF-8\""
            }
        )

async def is_media_type_application_json(request: Request):
    accept_header = request.headers.get("accept", None)
    supported_mime_types = ["*/*", "application/json"]
    if accept_header is None or not any(mime_type in accept_header for mime_type in supported_mime_types):
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=f"Unsupported MIME type in header 'Accept': '{accept_header}' or not provided."
                   f"This API only supports type 'application/json'."
        )
