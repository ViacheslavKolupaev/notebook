"""Module for local testing of the logging module."""

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

from src.boilerplate.custom_logger import LoggerWithMetadata
from src.boilerplate.schemas.common import MetadataOpt  # type: ignore[import]

_module_logger = LoggerWithMetadata().get_module_logger(name=__name__)


class LoggerTester(object):

    def __init__(self, metadata: MetadataOpt) -> None:
        self._metadata: MetadataOpt = metadata

    def log_error(self) -> None:
        _module_logger.error('Some useful log entry.', extra=self._metadata.dict())


def get_metadata() -> MetadataOpt:
    raw_metadata = {
        'idempotency_key': 'be53389f-92e9-4475-b6a3-2e2dd38a31f7',
        'task_id': 555,
        'callback_url': 'http://127.0.0.1:50000/callback_url',
    }
    return MetadataOpt.parse_obj(raw_metadata)


def main() -> None:
    metadata = get_metadata()
    lt = LoggerTester(metadata=metadata)

    for i in range(0, 5):
        lt.log_error()


if __name__ == '__main__':
    main()
