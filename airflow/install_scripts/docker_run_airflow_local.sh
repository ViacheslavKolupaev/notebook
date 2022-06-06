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

##########################################################################################
# The script will create and run a Docker container with standalone Apache Airflow.
#
# Not suitable for production environment. Use it for local development and testing only!
#
# The container will be named: `dev-apache-airflow-<AIRFLOW_VERSION>-<PYTHON_BASE_IMAGE>`.
# The Apache Airflow web server will be available at: http://127.0.0.1:8080/.
# For authorization use login `admin` and password `admin`.
#
# A directory `airflow_dags_dir` with DAG files from the host will be mounted to the
# container. Thus, if adding or changes to the DAG file, you do not need to rebuild the
# image and restart the container.
#
# If you need to add or remove some package (dependency) for Apache Airflow, then you
# need to:
# 1. Make changes to the `requirements.txt` file.
# 2. Rebuild the image using the `docker_build_airflow_local.sh` script.
# 3. Restart container with this script.
#
# If necessary, you need to replace the values of the variables in the `main()` function:
# - `airflow_dags_dir`;
# - `AIRFLOW_VERSION`;
# - `PYTHON_BASE_IMAGE`;
# - `docker_image_name`;
# - `docker_image_tag`.
##########################################################################################


#######################################
# Run standalone Apache Airflow in a Docker container.
# Globals:
#   FUNCNAME
# Arguments:
#   docker_image_name
#   docker_image_tag
#   airflow_dags_dir
#######################################
function docker_run_standalone_airflow_in_container() {
  echo ''
  log_to_stdout "Running standalone Apache Airflow in Docker container..."
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  if [ -z "$1" ] ; then
    log_to_stderr "${FUNCNAME[0]}: Argument 'docker_image_name' was not specified in the function call. Exit."
    exit 1
  else
    local docker_image_name
    docker_image_name=$1
    readonly docker_image_name
    log_to_stdout "${FUNCNAME[0]}: docker_image_name = ${docker_image_name}"
  fi

  if [ -z "$2" ] ; then
    log_to_stderr "${FUNCNAME[0]}: Argument 'docker_image_tag' was not specified in the function call. Exit."
    exit 1
  else
    local docker_image_tag
    docker_image_tag=$2
    readonly docker_image_tag
    log_to_stdout "${FUNCNAME[0]}: docker_image_tag = ${docker_image_tag}"
  fi

  if [ -z "$3" ] ; then
    log_to_stderr "${FUNCNAME[0]}: Argument 'airflow_dags_dir' was not specified in the function call. Exit."
    exit 1
  else
    local airflow_dags_dir
    airflow_dags_dir=$3
    readonly airflow_dags_dir
    log_to_stdout "${FUNCNAME[0]}: airflow_dags_dir = ${airflow_dags_dir}"
  fi

  # Docs: https://docs.docker.com/engine/reference/commandline/run/
  # Usage: docker run [OPTIONS] IMAGE[:TAG|@DIGEST] [COMMAND] [ARG...]
  if ! docker run \
    --detach \
    --rm \
    --restart=no \
    --log-driver=local `# https://docs.docker.com/config/containers/logging/local/` \
    --log-opt mode=non-blocking \
    --network=dev-apache-airflow-net \
    --publish 8080:8080 \
    --cpus="2" \
    --memory-reservation=3g \
    --memory=4g \
    --memory-swap=5g \
    --mount type=bind,source="${airflow_dags_dir}",target=/opt/airflow/dags,readonly \
    --health-cmd='python --version || exit 1' \
    --health-interval=2s \
    --env LANG=C.UTF-8 \
    --env IS_DEBUG=True  `# Not for production environment.` \
    --env "_AIRFLOW_DB_UPGRADE=true" \
    --env "_AIRFLOW_WWW_USER_CREATE=true" \
    --env "_AIRFLOW_WWW_USER_PASSWORD=admin" \
    --name "${docker_image_name}-${docker_image_tag}"  `# Container name.` \
    "${docker_image_name}:${docker_image_tag}"  `# The name and tag of the image to use to launch the container.` \
    standalone  `# The command to execute inside the container.`;
  then
    log_to_stderr 'Error starting container. Exit.'
    exit 1
  else
    log_to_stdout 'Docker container started successfully. Continue.'
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
}

function main() {
  # 1. Declaring Local Variables.
  local script_basename
  script_basename=$(basename "${BASH_SOURCE[0]##*/}")  # don't change
  readonly script_basename

  local airflow_dags_dir
  airflow_dags_dir="${HOME}/PycharmProjects/notebook/airflow/dags"  # change the path if necessary
  readonly airflow_dags_dir

  local AIRFLOW_VERSION
  readonly AIRFLOW_VERSION="2.2.4"

  local PYTHON_BASE_IMAGE
  readonly PYTHON_BASE_IMAGE="python3.8"

  local docker_image_name
  readonly docker_image_name='dev-apache-airflow'

  local docker_image_tag
  readonly docker_image_tag="${AIRFLOW_VERSION}-${PYTHON_BASE_IMAGE}"

  # 2. Import bash functions from other scripts.
  # shellcheck source=../../common_bash_functions.sh
  source ../../common_bash_functions.sh

  # 3. Execution of script logic.
  log_to_stdout "${script_basename}: START SCRIPT EXECUTION"

  docker_stop_and_remove_containers_by_name "${docker_image_name}-${docker_image_tag}"
  docker_stop_and_remove_containers_by_ancestor "${docker_image_name}" "${docker_image_tag}"
  docker_create_user_defined_bridge_network "${docker_image_name}"
  docker_run_standalone_airflow_in_container "${docker_image_name}" "${docker_image_tag}" "${airflow_dags_dir}"

  log_to_stdout "${script_basename}: END OF SCRIPT EXECUTION"
}

main "$@"
