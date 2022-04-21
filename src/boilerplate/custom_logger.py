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
#

import json
import logging
import sys
from typing import Any, Optional, Union

from typeguard import typechecked

from src.boilerplate.schemas.common import MetadataMan, MetadataOpt, EnvState
from src.boilerplate.config import config


class CustomAdapter(logging.LoggerAdapter):
    """
    An adapter for loggers which makes it easier to specify contextual information
    in logging output.

    Prepend fields from MetadataOpt to the beginning of log messages.
    """

    def _prepend_dict_vals_to_str(self, prepend_str: str, extra: dict):
        for key, val in extra.items():
            prepend_str += '{key}: {val} | '.format(key=key, val=str(val))

        return prepend_str

    @typechecked()
    def process(self, msg: str, kwargs: Any) -> tuple[str, dict]:
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
                prepend_str = self._prepend_dict_vals_to_str(
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
                prepend_str = self._prepend_dict_vals_to_str(
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

    # def make_error(self, msg: str, extra: Union[MetadataOpt, MetadataMan, dict], *args, **kwargs) -> None:
    #     self.error(msg, *args, **kwargs)


class LoggerWithMetadata(object):


    def __init__(self) -> None:
        self._logger_name: Optional[str] = None
        self._metadata: MetadataOpt = MetadataOpt()
        self.extra: Optional[Union[MetadataOpt, dict]] = None
        # self._default_stacklevel: int = 5
        # self._logger_w_metadata: Union[CustomAdapter, logging.Logger] = self._get_logger()

    def get_formatter(self) -> logging.Formatter:

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

    @typechecked()
    def get_root_logger(self) -> logging.Logger:
        """Get root logger."""
        root_logger: logging.Logger = logging.getLogger(name=None)

        console_handler: logging.StreamHandler = logging.StreamHandler(sys.stdout)
        error_handler: logging.StreamHandler = logging.StreamHandler(sys.stderr)

        root_logger.logThreads = False
        root_logger.logProcesses = False
        logging.logMultiprocessing = False
        root_logger.propagate = False

        if config.APP_ENV_STATE in (EnvState.development, EnvState.staging):
            root_logger.setLevel(logging.DEBUG)
            console_handler.setLevel(logging.DEBUG)
        else:
            root_logger.setLevel(logging.INFO)
            console_handler.setLevel(logging.INFO)

            # See: https://docs.python.org/3/howto/logging.html#exceptions-raised-during-logging
            root_logger.raiseExceptions = False

        error_handler.setLevel(logging.ERROR)

        console_handler.addFilter(LevelFilter(low=10, high=30))
        error_handler.addFilter(LevelFilter(low=40, high=50))

        formatter: logging.Formatter = self.get_formatter()

        console_handler.setFormatter(formatter)
        error_handler.setFormatter(formatter)

        root_logger.addHandler(console_handler)
        root_logger.addHandler(error_handler)

        return root_logger

    def get_module_logger(self, name: str) -> CustomAdapter:
        """Get logger with prepared handlers and extra dict."""

        logger: logging.Logger = logging.getLogger(name=name)

        logger.logThreads = False
        logger.logProcesses = False
        logging.logMultiprocessing = False
        logger.propagate = True

        if config.APP_ENV_STATE in (EnvState.development, EnvState.staging):
            logger.setLevel(logging.DEBUG)
        else:
            logger.setLevel(logging.INFO)

            # See: https://docs.python.org/3/howto/logging.html#exceptions-raised-during-logging
            logger.raiseExceptions = False

        return CustomAdapter(logger=logger, extra={'key_1': 'val_1'})


    # @typechecked()
    # def log(
    #     self,
    #     level: int,
    #     msg: str,
    #     extra: Optional[Union[MetadataOpt, MetadataMan]] = None,
    #     *args,
    #     **kwargs,
    # ) -> None:
    #     stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
    #     if extra:
    #         self.extra = extra
    #         self._logger_w_metadata.extra = extra.dict()
    #     self._logger_w_metadata.log(level, msg, *args, stacklevel=stacklevel, **kwargs)
    #
    #
    # @typechecked()
    # def debug(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
    #     stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
    #     self.extra = extra
    #     self._logger_w_metadata.extra = extra.dict()
    #     self._logger_w_metadata.debug(msg, *args, stacklevel=stacklevel, **kwargs)
    #
    #
    # @typechecked()
    # def info(self, msg: str, extra: Optional[Union[MetadataOpt, MetadataMan]] = None, *args, **kwargs) -> None:
    #     stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
    #     if extra:
    #         self.extra = extra
    #         self._logger_w_metadata.extra = extra.dict()
    #     self._logger_w_metadata.info(msg, *args, stacklevel=stacklevel, **kwargs)
    #
    #
    # @typechecked()
    # def warning(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
    #     stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
    #     self.extra = extra
    #     self._logger_w_metadata.extra = extra.dict()
    #     self._logger_w_metadata.warning(msg, *args, stacklevel=stacklevel, **kwargs)
    #
    #
    # @typechecked()
    # def error(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
    #     stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
    #     self.extra = extra
    #     self._logger_w_metadata.extra = extra.dict()
    #     self._logger_w_metadata.error(msg, *args, stacklevel=stacklevel, **kwargs)
    #
    #
    # @typechecked()
    # def critical(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
    #     stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
    #     self.extra = extra
    #     self._logger_w_metadata.extra = extra.dict()
    #     self._logger_w_metadata.critical(msg, *args, stacklevel=stacklevel, **kwargs)
    #
    #
    # @typechecked()
    # def exception(
    #         self,
    #         msg: str,
    #         extra: Union[MetadataOpt, MetadataMan],
    #         exc_info: Union[bool, Exception] = True,
    #         *args,
    #         **kwargs
    # ) ->  None:
    #     stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
    #     self.extra = extra
    #     self._logger_w_metadata.extra = extra.dict()
    #     self._logger_w_metadata.exception(msg, exc_info=exc_info, stacklevel=stacklevel, *args, **kwargs)


class LevelFilter(logging.Filter):

    def __init__(self, low: int, high: int) -> None:
        self._low = low
        self._high = high
        logging.Filter.__init__(self)

    def filter(self, record) -> bool:
        if self._low <= record.levelno <= self._high:
            return True
        return False
