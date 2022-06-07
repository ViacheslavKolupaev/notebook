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
# The script will build a Docker image with standalone Apache Airflow.
#
# Not suitable for production environment. Use it for local development and testing only!
#
# The image will be named: `dev-apache-airflow-<AIRFLOW_VERSION>-<PYTHON_BASE_IMAGE>`.
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
# - `dockerfile_dir`;
# - `AIRFLOW_VERSION`;
# - `PYTHON_BASE_IMAGE`;
# - `docker_image_name`;
# - `docker_image_tag`.
#
# See available Apache Airflow tags here: https://hub.docker.com/r/apache/airflow/tags
##########################################################################################


#######################################
# Build a standalone Apache Airflow docker image.
# Globals:
#   None
# Arguments:
#   docker_image_name
#   docker_image_tag
#   dockerfile_dir
#   AIRFLOW_VERSION
#   PYTHON_BASE_IMAGE
#######################################
function docker_build_standalone_airflow_image() {
  echo ''
  log_to_stdout ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  log_to_stdout "Building a standalone Apache Airflow Docker image..."

  # Checking function arguments.
  if [ -z "$1" ] ; then
    log_to_stderr "Argument 'docker_image_name' was not specified in the function call. Exit."
    exit 1
  else
    local docker_image_name
    docker_image_name=$1
    readonly docker_image_name
    log_to_stdout "docker_image_name = ${docker_image_name}"
  fi

  if [ -z "$2" ] ; then
    log_to_stderr "Argument 'docker_image_tag' was not specified in the function call. Exit."
    exit 1
  else
    local docker_image_tag
    docker_image_tag=$2
    readonly docker_image_tag
    log_to_stdout "docker_image_tag = ${docker_image_tag}"
  fi

  if [ -z "$3" ] ; then
    log_to_stderr "Argument 'dockerfile_dir' was not specified in the function call. Exit."
    exit 1
  else
    local dockerfile_dir
    dockerfile_dir=$3
    readonly dockerfile_dir
    log_to_stdout "dockerfile_dir = ${dockerfile_dir}"
  fi

  if [ -z "$4" ] ; then
    log_to_stderr "Argument 'AIRFLOW_VERSION' was not specified in the function call. Exit."
    exit 1
  else
    local AIRFLOW_VERSION
    AIRFLOW_VERSION=$4
    readonly AIRFLOW_VERSION
    log_to_stdout "AIRFLOW_VERSION = ${AIRFLOW_VERSION}"
  fi

  if [ -z "$5" ] ; then
    log_to_stderr "Argument 'PYTHON_BASE_IMAGE' was not specified in the function call. Exit."
    exit 1
  else
    local PYTHON_BASE_IMAGE
    PYTHON_BASE_IMAGE=$5
    readonly PYTHON_BASE_IMAGE
    log_to_stdout "PYTHON_BASE_IMAGE = ${PYTHON_BASE_IMAGE}"
  fi

  # Get the short SHA of the current Git revision.
  local git_rev_short_sha
  git_rev_short_sha="$(git rev-parse --short HEAD)"
  log_to_stdout "git_rev_short_sha: ${git_rev_short_sha}"

  # Building a Docker image.
  # See about DOCKER_BUILDKIT: https://github.com/moby/moby/issues/34151#issuecomment-739018493
  if ! DOCKER_BUILDKIT=1 docker build . \
       --pull \
       --file "${dockerfile_dir}/Dockerfile" \
       --build-arg VCS_REF="${git_rev_short_sha}" \
       --build-arg AIRFLOW_VERSION="${AIRFLOW_VERSION}" \
       --build-arg PYTHON_BASE_IMAGE="${PYTHON_BASE_IMAGE}" \
       --tag "${docker_image_name}:${docker_image_tag}"; then
    log_to_stderr 'Error building Docker image. Exit.'
    exit 1
  else
    log_to_stdout 'Docker image successfully built. Continue.'
  fi

  log_to_stdout "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
}

#######################################
# Run the main function of the script.
# Globals:
#   HOME
# Arguments:
#  None
#######################################
function main() {
  # 1. Declaring Local Variables.
  local dockerfile_dir
  dockerfile_dir="${HOME}/PycharmProjects/notebook/airflow/install_scripts"  # double check the path
  readonly dockerfile_dir

  local AIRFLOW_VERSION
  readonly AIRFLOW_VERSION="2.2.4"  # change if necessary

  local PYTHON_BASE_IMAGE
  readonly PYTHON_BASE_IMAGE="python3.8"  # change if necessary

  local docker_image_name
  readonly docker_image_name='dev-apache-airflow'  # change if necessary

  local docker_image_tag
  docker_image_tag="${AIRFLOW_VERSION}-${PYTHON_BASE_IMAGE}"  # don't change
  readonly docker_image_tag

  # 2. Import bash functions from other scripts.
  # shellcheck source=../../common_bash_functions.sh
  source ../../common_bash_functions.sh

  # 3. Execution of script logic.
  log_to_stdout "START SCRIPT EXECUTION."

  docker_image_remove_by_name_tag \
    "${docker_image_name}" \
    "${docker_image_tag}"

  docker_build_standalone_airflow_image \
    "${docker_image_name}" \
    "${docker_image_tag}" \
    "${dockerfile_dir}" \
    "${AIRFLOW_VERSION}" \
    "${PYTHON_BASE_IMAGE}"

  log_to_stdout "END OF SCRIPT EXECUTION."
}

main "$@"
