"""Logger configuration file."""

#  Copyright (c) 2022. Viacheslav Kolupaev,  https://viacheslavkolupaev.ru/
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

import json
import logging
import sys
from typing import Any, Optional, Union

from typeguard import typechecked

from src.boilerplate.schemas.common import MetadataMan, MetadataOpt
from src.boilerplate.config import config


class CustomAdapter(logging.LoggerAdapter):
    """Prepends fields from MetadataOpt to the beginning of log messages."""

    @typechecked()
    def process(self, msg: str, kwargs: Any) -> tuple[str, dict]:
        prepend_str = ''

        # if isinstance(self.extra, dict) and self.extra:
        #     for key, val in self.extra.items():
        #         prepend_str += '{key}: {val} | '.format(key=key, val=val)

        if self.extra.get('task_id'):
            prepend_str += 'task_id: %s | ' % (self.extra.get('task_id'))
        if self.extra.get('app_id'):
            prepend_str += 'app_id: %s | ' % (self.extra.get('app_id'))
        if self.extra.get('person_id'):
            prepend_str += 'person_id: %s | ' % (self.extra.get('person_id'))
        if self.extra.get('cognito_id'):
            prepend_str += 'cognito_id: %s | ' % (self.extra.get('cognito_id'))
        if self.extra.get('product_name'):
            prepend_str += 'product_name: %s | ' % (self.extra.get('product_name'))

        return prepend_str + '%s' % (msg), kwargs


def get_console_handler():
    console_handler = logging.StreamHandler(sys.stdout)

    log_message_in_dict = {
        "timestamp": "%(asctime)s",
        "level": "%(levelname)s",
        "name":  "%(name)s",
        "funcName": "%(funcName)s",
        "lineno": "%(lineno)d",
        "message": "%(message)s"
    }
    log_message_formatter_in_dict = logging.Formatter(
        json.dumps({**log_message_in_dict})
    )

    log_message_in_str = \
        "%(asctime)s | %(levelname)s:%(levelno)s | %(relativeCreated)d | %(filename)s | %(funcName)s:%(lineno)d | %(processName)s:%(process)d | " \
        "%(threadName)s:%(thread)d | %(message)s"

    log_message_formatter_in_str = logging.Formatter(log_message_in_str)

    console_handler.setFormatter(log_message_formatter_in_str)

    return console_handler


@typechecked()
def get_logger(*, logger_name: str):
    """Get logger with prepared handlers."""
    logger = logging.getLogger(logger_name)

    if config.IS_DEBUG:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

    logger.addHandler(get_console_handler())
    logger.propagate = False

    return logger


@typechecked()
def get_logger_w_extra(*, logger_name, extra: Optional[Union[MetadataMan, MetadataOpt]]):
    """Get logger with prepared handlers and extra dict."""
    logger = logging.getLogger(logger_name)

    if config.IS_DEBUG:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

    logger.addHandler(get_console_handler())
    logger.propagate = False

    if extra:
        adapter = CustomAdapter(logger, extra.dict())
        return adapter
    else:
        return logger


class LoggerWithExtra():


    @typechecked()
    def __init__(self, name: str):
        self.extra = MetadataOpt()
        self._logger_w_extra: Union[CustomAdapter, logging.Logger] = \
            get_logger_w_extra(
                logger_name=name,
                extra=self.extra
            )
        self._default_stacklevel: int = 5



    @typechecked()
    def log(self,
            level: int,
            msg: str,
            extra: Optional[Union[MetadataOpt, MetadataMan]] = None,
            *args,
            **kwargs
    ) -> None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        if extra:
            self.extra = extra
            self._logger_w_extra.extra = extra.dict()
        self._logger_w_extra.log(level, msg, *args, stacklevel=stacklevel, **kwargs)



    def debug(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        self.extra = extra
        self._logger_w_extra.extra = extra.dict()
        self._logger_w_extra.debug(msg, *args, stacklevel=stacklevel, **kwargs)

    @typechecked()
    def info(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        self.extra = extra
        self._logger_w_extra.extra = extra.dict()
        self._logger_w_extra.info(msg, *args, stacklevel=stacklevel, **kwargs)


    @typechecked()
    def warning(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        self.extra = extra
        self._logger_w_extra.extra = extra.dict()
        self._logger_w_extra.warning(msg, *args, stacklevel=stacklevel, **kwargs)


    @typechecked()
    def error(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        self.extra = extra
        self._logger_w_extra.extra = extra.dict()
        self._logger_w_extra.error(msg, *args, stacklevel=stacklevel, **kwargs)


    @typechecked()
    def critical(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        self.extra = extra
        self._logger_w_extra.extra = extra.dict()
        self._logger_w_extra.critical(msg, *args, stacklevel=stacklevel, **kwargs)


    @typechecked()
    def exception(
            self,
            msg: str,
            extra: Union[MetadataOpt, MetadataMan],
            exc_info: Union[bool, Exception] = True,
            *args,
            **kwargs
    ) ->  None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        self.extra = extra
        self._logger_w_extra.extra = extra.dict()
        self._logger_w_extra.exception(msg, exc_info=exc_info, stacklevel=stacklevel, *args, **kwargs)
