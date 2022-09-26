# ########################################################################################
#  Copyright 2022 Viacheslav Kolupaev; author's website address:
#
#      https://vkolupaev.com/?utm_source=c&utm_medium=link&utm_campaign=notebook
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
# ########################################################################################

"""The package contains helper functions and decorators for the Python package."""

import functools
from time import time_ns
from typing import Any, Callable

from src.boilerplate.custom_logger import CustomLogger

_module_logger = CustomLogger().get_module_logger(
    name=__name__,
    module_extra=None,  # optional data that will be added to each message of this logger
)


def calculate_running_time(
    stacklevel: int = 1,
    extra: dict[str, Any] | None = None,
) -> Callable[..., Any]:
    """Decorator for measuring the execution time of functions with additional arguments.

    Args:
        stacklevel: keyword argument for `logging.Logger.debug`.
        extra: `extra` dictionary for `CustomLogger`.

    Returns:
        decorated function.
    """
    def actual_decorator(func: Callable[..., Any]) -> Callable[..., Any]:  # noqa: WPS430
        """Actual decorator for measuring the execution time of functions.

        Args:
            func: decorated function.

        Returns:
            decorated function.

        """
        @functools.wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> Any:
            start_datetime = time_ns()
            func_returning = func(*args, **kwargs)
            end_datetime = time_ns()
            # Convert nanoseconds to milliseconds.
            running_time = (end_datetime - start_datetime) / (10**6)
            _module_logger.debug(
                msg="'{func_name}' running_time: {running_time} ms.".format(
                    func_name=func.__name__,
                    running_time=running_time,
                ),
                stacklevel=stacklevel,
                extra=extra,
            )
            return func_returning
        return wrapper
    return actual_decorator
