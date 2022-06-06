#!/bin/bash
#
# Copyright (c) 2022. Viacheslav Kolupaev, https://vkolupaev.com/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

function main() {
  export AIRFLOW_HOME=~/PycharmProjects/notebook/airflow
  pip install \
    "apache-airflow[celery]==2.3.1" \
    --constraint \
    "https://raw.githubusercontent.com/apache/airflow/constraints-2.3.1/constraints-3.10.txt"

  pip install apache-airflow-providers-docker
  pip install 'apache-airflow[sentry]'

  # The Standalone command will initialise the database, make a user,
  # and start all components for you.
  airflow standalone

  # Visit localhost:8080 in the browser and use the admin account details
  # shown on the terminal to login.
  # Enable the example_bash_operator dag in the home page

#  airflow db upgrade
#
#  airflow users create \
#    --role Admin \
#    --username admin \
#    --email admin \
#    --firstname admin \
#    --lastname admin \
#    --password admin
#
#  airflow webserver
#  airflow scheduler
}

main "$@"
