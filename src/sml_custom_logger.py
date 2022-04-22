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

"""Module for local testing of the logging module."""

from src.boilerplate.custom_logger import CustomLogger
from src.boilerplate.schemas.common import MetadataOpt  # type: ignore[import]

_module_logger = CustomLogger().get_module_logger(
    name=__name__,
    module_extra=None,  # optional data that will be added to each message of this logger
)


class LoggerTester(object):

    def __init__(self, metadata: MetadataOpt) -> None:
        self._metadata: MetadataOpt = metadata

    def log_info(self) -> None:
        _module_logger.info(
            msg='Application progress: {app_progress}.'.format(app_progress='OK'),
            extra={'key_2': 'val_2'},
        )

    def log_error(self) -> None:
        """Make a log message of the `exception` level.

        Due to a more serious problem, the software has not been able to perform some
        function.
        """

        _module_logger.error(
            msg='Application progress: {app_progress}.'.format(app_progress='Some error occurred...'),
            extra=self._metadata.dict(),
        )

    def log_exception(self) -> None:
        """Log an `ERROR` level message with additional information about the exception.

        Logs a message with level `ERROR` on this logger. The arguments are interpreted as
        for `debug()`. Exception info is added to the logging message.

        Attention! This method should only be called from an exception handler.
        """
        try:
            1/0
        except ZeroDivisionError as exc:
            _module_logger.exception(
                msg='Application progress: {app_progress}.'.format(
                    app_progress='Oops, something seems to be broken...',
                ),
                exc_info=True,  # enabled by default for `exception` level
                stack_info=True,  # enabled for demo purposes only
                extra=self._metadata.dict(),
            )
            # raise exc  # send an exception one level up (sometimes this is not required)

    def log_critical(self) -> None:
        """Make a log message of the `exception` level.

        Due to a more serious problem, the software has not been able to perform some
        function.
        """
        _module_logger.critical(
            msg='Application progress: {app_progress}.'.format(
                app_progress='A serious error, indicating that the program itself may be unable to continue running.'
            ),
            extra=self._metadata.dict(),
        )


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

    lt.log_info()
    lt.log_error()
    lt.log_exception()
    lt.log_critical()


if __name__ == '__main__':
    main()
