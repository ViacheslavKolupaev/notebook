"""Logger configuration file."""

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

import json
import logging
import sys
from typing import Any, Optional, Tuple, Union

from typeguard import typechecked

from src.boilerplate.config import config
from src.boilerplate.schemas.common import EnvState, MetadataOpt  # type: ignore[import]


class CustomAdapter(logging.LoggerAdapter):  # type: ignore[type-arg]
    """An adapter for loggers.

    Makes it easier to specify contextual information in logging output.

    Adds the keys and values from the "extra" keyword argument dictionary to the
    beginning of the log messages.
    """

    @typechecked()
    def process(self, msg: str, kwargs: Any) -> tuple[str, Any]:
        """Process the logging message.

        Process the logging message and keyword arguments passed in to a logging call
        to insert contextual information.

        Return the message and kwargs modified (or not) to suit your needs.
        """
        prepend_str = ''

        # This is the presence check and handling of the `extra` keyword argument
        # when the adapter class is instantiated, for example:
        # `CustomAdapter(logger=some_logger, extra=some_dict)`
        if self.extra:
            if isinstance(self.extra, dict):
                prepend_str = self._prepend_extra_dict_to_str(
                    prepend_str=prepend_str,
                    extra=self.extra,
                )
            else:
                err_msg = (
                    'Incorrect type of the "extra" keyword argument in the ' +
                    '"CustomAdapter" constructor: {type_of_extra}. Dictionary expected.'
                ).format(type_of_extra=type(self.extra))
                raise TypeError(err_msg)

        # This is the presence check and handling of the `extra` keyword argument
        # when calling the module's logger method, for example:
        # `_module_logger.debug(msg='some_message', extra=some_dict)`
        if 'extra' in kwargs and kwargs['extra']:
            if isinstance(kwargs['extra'], dict):
                prepend_str = self._prepend_extra_dict_to_str(
                    prepend_str=prepend_str,
                    extra=kwargs['extra'],
                )
            else:
                err_msg = (
                    'Incorrect type of the "extra" keyword argument in the module ' +
                    'logger method call: {type_of_extra}. Dictionary expected.'
                ).format(type_of_extra=type(kwargs['extra']))
                raise TypeError(err_msg)

        processed_msg = prepend_str + '{msg}'.format(msg=msg)

        return processed_msg, kwargs

    @typechecked()
    def _prepend_extra_dict_to_str(self, prepend_str: str, extra: dict[str, Any]) -> str:
        for extra_key, extra_val in extra.items():  # noqa: WPS519
            prepend_str += '{key}: {val} | '.format(key=extra_key, val=str(extra_val))

        return prepend_str


class LevelFilter(logging.Filter):

    def __init__(self, low: int, high: int) -> None:
        self._low = low
        self._high = high
        logging.Filter.__init__(self)

    def filter(self, record: logging.LogRecord) -> bool:
        if self._low <= record.levelno <= self._high:
            return True
        return False


class CustomLogger(object):


    def _get_root_logger_formatter(self) -> logging.Formatter:

        log_message_in_dict = {
            "timestamp": "%(asctime)s",
            "level": "%(levelname)s",
            "name": "%(name)s",
            "funcName": "%(funcName)s",
            "lineno": "%(lineno)d",
            "message": "%(message)s"
        }
        log_message_formatter_in_dict = logging.Formatter(
            json.dumps({**log_message_in_dict})
        )

        log_message_in_str = \
            "%(asctime)s | %(levelname)s:%(levelno)s | %(relativeCreated)d | %(filename)s | %(funcName)s:%(lineno)d | " \
            "%(message)s"

        log_message_formatter_in_str = logging.Formatter(log_message_in_str)

        return log_message_formatter_in_str


    def _configure_logger(self, logger: logging.Logger) -> logging.Logger:
        logger.logThreads = False
        logger.logProcesses = False
        logger.logMultiprocessing = False

        if logger.name == 'root':
            logger.propagate = False
        else:
            logger.propagate = True

        if config.APP_ENV_STATE in (EnvState.development, EnvState.staging):
            logger.setLevel(logging.DEBUG)
        else:
            logger.setLevel(logging.INFO)

            # See: https://docs.python.org/3/howto/logging.html#exceptions-raised-during-logging
            logger.raiseExceptions = False

        return logger


    def _get_root_logger_console_handler(
        self,
        formatter: logging.Formatter,
    ) -> logging.StreamHandler:  # type: ignore[type-arg]
        console_handler = logging.StreamHandler(stream=sys.stdout)

        if config.APP_ENV_STATE in (EnvState.development, EnvState.staging):
            console_handler.setLevel(logging.DEBUG)
        else:
            console_handler.setLevel(logging.INFO)

        console_handler.addFilter(LevelFilter(low=10, high=30))
        console_handler.setFormatter(formatter)

        return console_handler


    def _get_root_logger_error_handler(
        self,
        formatter: logging.Formatter,
    ) -> logging.StreamHandler:  # type: ignore[type-arg]
        error_handler = logging.StreamHandler(stream=sys.stderr)
        error_handler.setLevel(logging.ERROR)
        error_handler.addFilter(LevelFilter(low=40, high=50))
        error_handler.setFormatter(formatter)

        return error_handler


    def get_root_logger(self) -> logging.Logger:
        """Get root logger."""
        root_logger = logging.getLogger(name=None)
        root_logger = self._configure_logger(logger=root_logger)

        formatter = self._get_root_logger_formatter()
        console_handler = self._get_root_logger_console_handler(formatter=formatter)
        error_handler = self._get_root_logger_error_handler(formatter=formatter)
        root_logger.addHandler(console_handler)
        root_logger.addHandler(error_handler)

        return root_logger


    @typechecked()
    def get_module_logger(
        self,
        name: str,
        module_extra: Optional[dict[str, Any]] = None,
    ) -> CustomAdapter:
        """Get logger with prepared handlers and extra dict."""
        module_logger = logging.getLogger(name=name)
        module_logger = self._configure_logger(logger=module_logger)
        adapter = CustomAdapter(logger=module_logger, extra=module_extra)

        return adapter
