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

"""Custom application logger.

Use this module to log the events of your Python application to `stdout` and/or `stderr`.

The module contains three classes:

  * `CustomLogger` — use this class to get loggers.
  * `CustomAdapter` — helper class.
  * `LevelFilter` — helper class.

Todo:
    * Improve the module for sending json messages to Apache Kafka.
    * Refine docstrings for a clearer understanding.

"""

import logging
import sys
from typing import Any, Final, TypeAlias

from typeguard import typechecked

from src.boilerplate.config import config
from src.boilerplate.schemas.common import EnvState  # type: ignore[import]

allowed_dict_val_types: TypeAlias = str | int | float | bool


class CustomAdapter(logging.LoggerAdapter):  # type: ignore[type-arg]
    """Custom adapter for logger.

    Adds the keys and values from the `extra` keyword argument dictionary to the
    beginning of the log messages.
    """

    @typechecked()
    def process(self, msg: str, kwargs: Any) -> tuple[str, Any]:
        """Process the logging message.

        Process the logging message and keyword arguments passed in to a logging call
        to insert contextual information. Contextual information is passed through
        `extra` keyword arguments.

        Args:
            msg: Logging message `logging.LogRecord.msg` passed in to a logging call.
            kwargs: Keyword arguments passed in to a logging call.

        Returns:
            * Log message with data from `extra` dictionaries added to its beginning.
            * Keyword arguments passed in to a logging call without any changes being made
              to them.

        Raises:
            TypeError: If the received `extra` keyword argument is not of type `dict`.

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
    """Filter log records by their level."""

    @typechecked()
    def __init__(self, low: int, high: int) -> None:
        """Perform custom instantiation of the class.

        Args:
            low: log records below this level will be filtered
            high: log records above this level will be filtered

        """
        self._low = low
        self._high = high
        self._validate_arguments()
        super().__init__()

    def filter(self, record: logging.LogRecord) -> bool:
        """Apply filters to log entries before passing them to handlers.

        In the current implementation, log entries are filtered only by their level.

        Args:
            record: A LogRecord instance represents an event being logged.

        Returns:
            * if `True`, the record will be processed (passed to handlers);
            * if `False`, no further processing of the record occurs.

        """
        return self._low <= record.levelno <= self._high

    def _validate_arguments(self) -> None:
        # See: https://docs.python.org/3/howto/logging.html#logging-levels
        allowed_levels: Final[set[int]] = {10, 20, 30, 40, 50}

        if self._low not in allowed_levels or self._high not in allowed_levels:
            raise ValueError(
                'An invalid "high" or "low" argument value was received. ' +
                'Allowed values: {allowed_levels}'.format(allowed_levels=allowed_levels),
            )

        if self._low > self._high:
            raise ValueError('The value of the "low" argument must be <= "high".')


class CustomLogger(object):
    """Custom application logger.

    Usage:
        * Use the `get_root_logger` method to get the `root` logger at the root of your
          application.
        * Use the `get_module_logger` method to get the logger in any child application
          module.

    """

    def get_root_logger(self) -> logging.Logger:
        """Get root logger.

        Initialize the `root` logger in only one place, for example here:
        `src/boilerplate/__init__.py`.

        Examples:
            ```
            from src.boilerplate.custom_logger import CustomLogger
            _root_logger = CustomLogger().get_root_logger()
            _root_logger.info('The root logger has been initialized.')
            ```

        Returns:
            Root logger. The method is idempotent because the `logging.getLogger`
            method it calls is idempotent.

        """
        root_logger = logging.getLogger(name=None)
        root_logger = self._configure_logger(logger=root_logger)

        formatter = self.get_root_logger_formatter()
        console_handler = self._get_root_logger_console_handler(formatter=formatter)
        error_handler = self._get_root_logger_error_handler(formatter=formatter)
        root_logger.addHandler(console_handler)
        root_logger.addHandler(error_handler)

        return root_logger

    @typechecked()
    def get_module_logger(
        self,
        name: str,
        module_extra: dict[str, allowed_dict_val_types] | None = None,
    ) -> CustomAdapter:
        """Get logger with prepared handlers and extra dict."""
        if module_extra is None:
            module_extra = {
                'env_state': config.APP_ENV_STATE,
                'commit_sha': config.APP_CI_COMMIT_SHA,
            }

        module_logger = logging.getLogger(name=name)
        module_logger = self._configure_logger(logger=module_logger)

        return CustomAdapter(logger=module_logger, extra=module_extra)

    def get_root_logger_formatter(self) -> logging.Formatter:
        """Get a formatter for the root logger.

        The method adds some attributes to the `LogRecord`. For a complete list of
        attributes, see the `logging` [documentation](
        https://docs.python.org/3/library/logging.html#logrecord-attributes).

        Returns:
            New instance of `Formatter` class with log message pattern applied.

        """
        log_message_pattern = (
            '{asctime} | ' +
            '{levelname}:{levelno} | ' +
            '{relativeCreated:.0f} | ' +
            '{filename} | ' +
            '{funcName}:{lineno:d} | ' +
            '{message}'
        )

        return logging.Formatter(fmt=log_message_pattern, style='{')

    def _configure_logger(self, logger: logging.Logger) -> logging.Logger:
        logger.logThreads = False
        logger.logProcesses = False
        logger.logMultiprocessing = False

        is_root = bool(logger.name == 'root')
        logger.propagate = not (is_root)

        if config.APP_ENV_STATE in {EnvState.development, EnvState.staging}:
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

        if config.APP_ENV_STATE in {EnvState.development, EnvState.staging}:
            console_handler.setLevel(logging.DEBUG)
        else:
            console_handler.setLevel(logging.INFO)

        console_handler.addFilter(LevelFilter(low=logging.DEBUG, high=logging.WARNING))
        console_handler.setFormatter(formatter)

        return console_handler

    def _get_root_logger_error_handler(
        self,
        formatter: logging.Formatter,
    ) -> logging.StreamHandler:  # type: ignore[type-arg]
        error_handler = logging.StreamHandler(stream=sys.stderr)
        error_handler.setLevel(logging.ERROR)
        error_handler.addFilter(LevelFilter(low=logging.ERROR, high=logging.CRITICAL))
        error_handler.setFormatter(formatter)

        return error_handler
