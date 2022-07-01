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

import logging

from locust import FastHttpUser, HttpUser, between, events, tag, task


@events.quitting.add_listener
def _(environment, **kw):
    """Set the exit code to non-zero.

    Set the exit code to non-zero if any of the following conditions are met:
        * More than 1% of the requests failed.
        * The average response time is longer than 200 ms.
        * The 95th percentile for response time is larger than 1000 ms.
    """
    if environment.stats.total.fail_ratio > 0.01:
        logging.error("Test failed due to failure ratio > 1%")
        environment.process_exit_code = 1
    elif environment.stats.total.avg_response_time > 200:
        logging.error("Test failed due to average response time ratio > 200 ms")
        environment.process_exit_code = 1
    elif environment.stats.total.get_response_time_percentile(0.95) > 1000:
        logging.error("Test failed due to 95th percentile response time > 1000 ms")
        environment.process_exit_code = 1
    else:
        environment.process_exit_code = 0


class FastApiUser(FastHttpUser):
    concurrency = 10
    wait_time = between(1, 5)

    @tag('fast', 'rest_api')
    @task(1)
    def get_root(self):
        self.client.get(
            url='/',
            json=None,
        )
