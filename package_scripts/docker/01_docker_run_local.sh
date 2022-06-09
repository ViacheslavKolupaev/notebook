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
# The script will create and run the Docker application container based on the image.
#
# Use it for local development and testing.
#
# If necessary, you need to replace the values of the variables in the `main()` function:
# - `docker_image_name`;
# - `docker_image_tag`;
# - `service_port`; make sure it matches the application config.
##########################################################################################


#######################################
# Launch a new application Docker container.
# Globals:
#   FUNCNAME
# Arguments:
#   docker_image_name
#   docker_image_tag
#   service_port
#######################################
function docker_run_container() {
  echo ''
  log_to_stdout "Running a Docker container based on the <name>:<tag> image..."
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
    log_to_stderr "${FUNCNAME[0]}: Argument 'service_port' was not specified in the function call. Exit."
    exit 1
  else
    local service_port
    service_port=$3
    readonly service_port
    log_to_stdout "${FUNCNAME[0]}: service_port = ${service_port}"
  fi

  # Docs: https://docs.docker.com/engine/reference/commandline/run/
  # Usage: docker run [OPTIONS] IMAGE[:TAG|@DIGEST] [COMMAND] [ARG...]
  if ! docker run \
        --detach \
        --rm \
        --restart=no \
        --log-driver=local `# https://docs.docker.com/config/containers/logging/local/` \
        --log-opt mode=non-blocking \
        --network="${docker_image_name}"-net \
        --publish "${service_port}":"${service_port}" \
        --cpus="0.5" \
        --memory-reservation=50m \
        --memory=100m \
        --memory-swap=200m \
        --health-cmd='python --version || exit 1' \
        --health-interval=2s \
        --env LANG=C.UTF-8 \
        --env IS_DEBUG=True  `# Not for production environment.` \
        --env-file=../../.env  `# Double-check the path and content.` \
        --name "${docker_image_name}"  `# Container name.` \
        "${docker_image_name}:${docker_image_tag}"  `# The name and tag of the image to use to launch the container.`;
  then
    log_to_stderr 'Error starting container. Exit.'
    exit 1
  else
    log_to_stdout 'Docker container started successfully. Continue.'
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
}

#######################################
# Run the main function of the script.
# Globals:
#   BASH_SOURCE
#   HOME
#   PWD
# Arguments:
#  None
#######################################
function main() {
  # 1. Declaring Local Variables.
  local docker_image_name
  readonly docker_image_name='boilerplate'  # refers to `${project_root}/src/boilerplate`

  local docker_image_tag
  readonly docker_image_tag='latest'

  local service_port
  readonly service_port=50000

  # 2. Import bash functions from other scripts.

  # shellcheck source=../../common_bash_functions.sh
  source ../../common_bash_functions.sh

  # 3. Execution of script logic.
  log_to_stdout 'START SCRIPT EXECUTION.'

  docker_stop_and_remove_containers_by_name "${docker_image_name}"
  docker_stop_and_remove_containers_by_ancestor "${docker_image_name}" "${docker_image_tag}"
  docker_create_user_defined_bridge_network "${docker_image_name}"
  docker_run_container "${docker_image_name}" "${docker_image_tag}" "${service_port}"

  log_to_stdout 'END OF SCRIPT EXECUTION.'
}

main "$@"
