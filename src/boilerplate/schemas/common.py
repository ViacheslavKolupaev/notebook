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
#

from datetime import datetime
from enum import Enum
from typing import Any, Final, Optional

from pydantic import UUID4, BaseModel, Field, HttpUrl, NonNegativeInt, PositiveInt, constr, validator

from src.boilerplate.pydantic_helpers import replace_empty_values_to_none

DATETIME_EXAMPLE: Final[str] = '2021-09-15T11:23:04.055239+00:00'


# Common.
class EnvState(str, Enum):
    development = 'development'
    staging = 'staging'
    production = 'production'


class CreatedDatetimeMan(BaseModel):
    created_datetime: datetime = Field(
        title='created_datetime',
        description='Datetime with time zone (UTC) when the DB record was created.',
        example=DATETIME_EXAMPLE
    )


class UpdatedDatetimeMan(BaseModel):
    updated_datetime: datetime = Field(
        title='updated_datetime',
        description='Datetime with time zone (UTC) when the DB record was updated.',
        example=DATETIME_EXAMPLE
    )


class ErrorMessageSchema(BaseModel):
    """Risk module `error_message` model.

    It is used for parsing API responses and writing data
    to the corresponding fields of the database tables.
    """
    error_message: Optional[dict[constr(min_length=1, strip_whitespace=True), Any]]


class ErrorNameSchema(BaseModel):
    error_name: Optional[constr(min_length=1, strip_whitespace=True)]

    class Config:
        use_enum_values = True


class ErrorSourceSchema(BaseModel):
    error_source: Optional[constr(min_length=1, strip_whitespace=True)]


class ErrorSchema(
    ErrorNameSchema,
    ErrorMessageSchema,
    ErrorSourceSchema
):
    class Config:
        use_enum_values = True


class HTTPResponseStatusCodeSchema(BaseModel):
    http_response_status_code: Optional[NonNegativeInt]


class HTTPResponseStatusReasonSchema(BaseModel):
    http_response_status_reason: Optional[constr(min_length=1, strip_whitespace=True)]

    class Config:
        use_enum_values = True


# Mandatory.
class IdMan(BaseModel):
    id: NonNegativeInt = Field(
        title='id',
        description='The `ID` of the entry or item.',
        example=1
    )


class TaskIdMan(BaseModel):
    task_id: PositiveInt = Field(
        title='task_id',
        description='The `id` of the asynchronous background task. '
                    'You can use it to get the processing result at the URL, passed in the `Location` header.',
        example=1
    )


class IdempotencyKeyMan(BaseModel):
    idempotency_key: UUID4 = Field(
        title='idempotency_key',
        description='Idempotency key — v4 UUID.',
        example='0d2b4fdd-1162-4ce7-b6b6-99f7b896926d'
    )


class IsErrorMan(BaseModel):
    """True means there is an error."""
    is_error: bool


# Optional.
class TaskIdOpt(BaseModel):
    task_id: Optional[PositiveInt]


class CallbackUrlOpt(BaseModel):
    callback_url: Optional[HttpUrl]


class IdempotencyKeyOpt(BaseModel):
    idempotency_key: Optional[UUID4]



# Metadata models.
class MetadataOpt(
    IdempotencyKeyOpt,
    TaskIdOpt,
    CallbackUrlOpt,
):
    """Metadata Extended model with optional fields."""
    pass


class MetadataMan(
    IdempotencyKeyMan,
    TaskIdMan,
    CallbackUrlOpt,
):
    """Metadata Extended model with mandatory fields."""
    pass
