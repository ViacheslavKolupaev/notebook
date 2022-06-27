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

"""Sentry initialization module.

Sampling is not used for `development` and `staging` environments.
For other environments, it is applied with a factor of 0.2.
"""

import sentry_sdk

from src.boilerplate.config import config
from src.boilerplate.schemas.common import EnvState


def init_sentry() -> None:
    """Initialize Sentry."""
    def _traces_sampler(sampling_context: dict) -> float:
        if config.SENTRY_ENVIRONMENT in {EnvState.development, EnvState.staging}:
            traces_sampler_lvl = 1.0
        else:
            traces_sampler_lvl = 0.2

        return traces_sampler_lvl

    # Sentry configuration options: https://docs.sentry.io/platforms/python/guides/asgi/configuration/options
    sentry_sdk.init(
        dsn=config.SENTRY_DSN,
        debug=False,
        release=config.SENTRY_RELEASE,
        environment=config.SENTRY_ENVIRONMENT,
        request_bodies='medium',
        with_locals=False,
        traces_sampler=_traces_sampler,
    )
    sentry_sdk.set_tag('app_name', config.APP_NAME)
