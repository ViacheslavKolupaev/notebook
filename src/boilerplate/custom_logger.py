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

from src.boilerplate.schemas.common import MetadataMan, MetadataOpt, EnvState
from src.boilerplate.config import config


class CustomAdapter(logging.LoggerAdapter):
    """Prepends fields from MetadataOpt to the beginning of log messages."""

    @typechecked()
    def process(self, msg: str, kwargs: Any) -> tuple[str, dict]:
        prepend_str = ''

        if isinstance(self.extra, dict) and self.extra:
            for key, val in self.extra.items():
                prepend_str += '{key}: {val} | '.format(key=key, val=str(val))

        return prepend_str + '%s' % (msg), kwargs

class LoggerWithMetadata():

    @typechecked()
    def __init__(self, name: Optional[str]) -> None:
        self._logger_name: Optional[str] = name

        self._metadata: MetadataOpt = MetadataOpt()
        self.extra: MetadataOpt = MetadataOpt()

        self._default_stacklevel: int = 5
        self._logger_w_metadata: Union[CustomAdapter, logging.Logger] = self._get_logger()


    @typechecked()
    def _get_logger(self) -> Union[CustomAdapter, logging.Logger]:
        if not self._logger_name:
            return self.get_root_logger_w_metadata()

        return self.get_module_logger_w_metadata()


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
    def get_root_logger_w_metadata(
        self,
        # *,
        # logger_name: Optional[str],
        # extra: Union[MetadataMan, MetadataOpt],
    ) -> Union[CustomAdapter, logging.Logger]:
        """Get logger with prepared handlers and extra dict."""

        logger: logging.Logger = logging.getLogger(self._logger_name)

        console_handler: logging.StreamHandler = logging.StreamHandler(sys.stdout)
        error_handler: logging.StreamHandler = logging.StreamHandler(sys.stderr)

        logger.logThreads = False
        logger.logProcesses = False
        logging.logMultiprocessing = False
        logger.propagate = False

        if config.APP_ENV_STATE in (EnvState.development, EnvState.staging):
            logger.setLevel(logging.DEBUG)
            console_handler.setLevel(logging.DEBUG)
        else:
            logger.setLevel(logging.INFO)
            console_handler.setLevel(logging.INFO)

            # See: https://docs.python.org/3/howto/logging.html#exceptions-raised-during-logging
            logger.raiseExceptions = False

        error_handler.setLevel(logging.ERROR)

        console_handler.addFilter(LevelFilter(low=10, high=30))
        error_handler.addFilter(LevelFilter(low=40, high=50))

        formatter: logging.Formatter = self.get_formatter()

        console_handler.setFormatter(formatter)
        error_handler.setFormatter(formatter)

        logger.addHandler(console_handler)
        logger.addHandler(error_handler)

        if self.extra:
            adapter = CustomAdapter(logger, self.extra.dict())
            return adapter
        else:
            return logger

    def get_module_logger_w_metadata(
        self,
        # *,
        # logger_name: Optional[str],
        # extra: Union[MetadataMan, MetadataOpt],
    ) -> Union[CustomAdapter, logging.Logger]:
        """Get logger with prepared handlers and extra dict."""

        logger: logging.Logger = logging.getLogger(self._logger_name)

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

        if self.extra:
            adapter = CustomAdapter(logger, self.extra.dict())
            return adapter
        else:
            return logger

    @typechecked()
    def log(
        self,
        level: int,
        msg: str,
        extra: Optional[Union[MetadataOpt, MetadataMan]] = None,
        *args,
        **kwargs,
    ) -> None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        if extra:
            self.extra = extra
            self._logger_w_metadata.extra = extra.dict()
        self._logger_w_metadata.log(level, msg, *args, stacklevel=stacklevel, **kwargs)


    @typechecked()
    def debug(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        self.extra = extra
        self._logger_w_metadata.extra = extra.dict()
        self._logger_w_metadata.debug(msg, *args, stacklevel=stacklevel, **kwargs)


    @typechecked()
    def info(self, msg: str, extra: Optional[Union[MetadataOpt, MetadataMan]] = None, *args, **kwargs) -> None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        if extra:
            self.extra = extra
            self._logger_w_metadata.extra = extra.dict()
        self._logger_w_metadata.info(msg, *args, stacklevel=stacklevel, **kwargs)


    @typechecked()
    def warning(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        self.extra = extra
        self._logger_w_metadata.extra = extra.dict()
        self._logger_w_metadata.warning(msg, *args, stacklevel=stacklevel, **kwargs)


    @typechecked()
    def error(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        self.extra = extra
        self._logger_w_metadata.extra = extra.dict()
        self._logger_w_metadata.error(msg, *args, stacklevel=stacklevel, **kwargs)


    @typechecked()
    def critical(self, msg: str, extra: Union[MetadataOpt, MetadataMan], *args, **kwargs) -> None:
        stacklevel = kwargs.pop('stacklevel', self._default_stacklevel)
        self.extra = extra
        self._logger_w_metadata.extra = extra.dict()
        self._logger_w_metadata.critical(msg, *args, stacklevel=stacklevel, **kwargs)


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
        self._logger_w_metadata.extra = extra.dict()
        self._logger_w_metadata.exception(msg, exc_info=exc_info, stacklevel=stacklevel, *args, **kwargs)


class LevelFilter(logging.Filter):

    def __init__(self, low: int, high: int) -> None:
        self._low = low
        self._high = high
        logging.Filter.__init__(self)

    def filter(self, record) -> bool:
        if self._low <= record.levelno <= self._high:
            return True
        return False
