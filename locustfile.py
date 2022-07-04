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

"""API load testing module using the locust library."""

import logging
from typing import Any

from locust import between, env, events, tag, task
from locust_plugins.users import RestUser


@events.quitting.add_listener
def _(environment: env.Environment, **kw: Any) -> None:
    """Set the exit code to non-zero.

    Set the exit code to non-zero if any of the following conditions are met:
        * More than 1% of the requests failed.
        * The average response time is longer than 200 ms.
        * The 95th percentile for response time is larger than 1000 ms.

    `quitting` — EventHook. Fired after quitting events, just before process is exited.

    Args:
        environment: locust Environment instance.
        kw: Keyword arguments passed in to a function call.
    """
    if environment.stats.total.fail_ratio * 100 > 1:
        logging.error('Test failed due to failure ratio > 1%')
        environment.process_exit_code = 1
    elif environment.stats.total.avg_response_time > 200:
        logging.error('Test failed due to average response time ratio > 200 ms')
        environment.process_exit_code = 1
    elif environment.stats.total.get_response_time_percentile(0.95) > 1000:
        logging.error('Test failed due to 95th percentile response time > 1000 ms')
        environment.process_exit_code = 1
    else:
        environment.process_exit_code = 0


class FastApiRestUser(RestUser):
    """The user to test the REST API.

    Uses `locust_plugins`.
    Code example:https://github.com/SvenskaSpel/locust-plugins/blob/master/examples/rest_ex.py
    """
    host = 'http://127.0.0.1:50000'
    concurrency = 10
    wait_time = between(1, 5)

    @tag('fast', 'rest_api')
    @task(1)
    def test_api_root_response_with_get_request(self) -> None:
        """Test the API root response with a GET request."""
        with self.rest(
            method='GET',
            url='/',
            headers=None,
            json={'message': 'Hey there! How are you?'},
        ) as resp:
            if not resp.js:
                resp.failure(
                    'resp.js is None, which it will be when there is a connection failure, a non-json responses etc.',
                )

            if resp.js and 'error' in resp.js and resp.js['error'] is not None:
                resp.failure(resp.js['error'])

            # Answer check option #1.
            if resp.js['message'] != "Thanks, I'm fine!":
                resp.failure("Unexpected value of 'message' in response: {resp_text}.".format(resp_text=resp.text))

            # Answer check option #2.
            # The `AssertionError` they raise will be caught by rest() and mark the
            # request as failed with the message 'Assertion failed'. For details, see the library code.
            assert resp.js['message'] == "Thanks, I'm fine!", (
                "Unexpected value of 'message' in response: {resp_text}.".format(resp_text=resp.text)
            )
