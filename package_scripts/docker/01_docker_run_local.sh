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

# ########################################################################################
# The script will create and run the Docker application container based on the image.
#
# Use it for local development and testing.
#
# If necessary, you need to replace the values of the variables in the `main()` function:
# - project_name;
# - docker_image_name;
# - docker_image_tag;
# - service_port; make sure it matches the application config.
##########################################################################################

#######################################
# Stop and remove containers with a name equal to the image name.
# Globals:
#   container_id
#   docker_image_name
# Arguments:
#  None
#######################################
function delete_containers_by_name() {
  # Getting a list of containers with a name equal to the name of the image.
  local container_ids
  container_ids="$(docker ps -aq -f "name=${docker_image_name}")"

  # Stop and remove containers.
  if [[ -n "${container_ids}" ]]; then
    log_to_stdout "Found containers named '${docker_image_name}': ${container_ids}."

    for container_id in "${container_ids[@]}"; do
      stop_container "${container_id}"
      if [ "$(docker ps -aq -f status=exited -f id="${container_id}")" ]; then
          remove_container "${container_id}"
      fi
    done
  else
    log_to_stdout "There are no containers named '${docker_image_name}'. Continue."
  fi
}

#######################################
# Stop and delete containers created from the image.
# Globals:
#   container_id
#   docker_image
# Arguments:
#  None
#######################################
function delete_containers_by_ancestor() {
  # Get a list of containers created based on the specified image.
  local container_ids
  container_ids="$(docker ps -aq -f "ancestor=${docker_image}")"

  # Stop and remove containers.
  if [[ -n "${container_ids}" ]]; then
    log_to_stdout "Containers created from '${docker_image}' image found: ${container_ids}."

    for container_id in "${container_ids[@]}"; do
      stop_container "${container_id}"
      if [ "$(docker ps -aq -f status=exited -f id="${container_id}")" ]; then
          remove_container "${container_id}"
      fi
    done
  else
    log_to_stdout "There are no containers running from the '${docker_image}' image. Continue."
  fi
}

#######################################
# Stop and delete running containers before starting a new one.
# Arguments:
#  None
#######################################
function docker_pre_cleanup() {
  log_to_stdout 'STEP 1: Docker pre-cleanup...'
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

#  delete_containers_by_name "$@"
  delete_containers_by_ancestor "$@"

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
}

#######################################
# Launch a new application Docker container.
# Globals:
#   docker_image
#   docker_image_name
#   service_port
# Arguments:
#  None
#######################################
function docker_run_container() {
  log_to_stdout "STEP 2: Running a Docker container based on the '${docker_image}' image..."
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  # Docs: https://docs.docker.com/engine/reference/commandline/run/
  if ! docker run \
        --log-opt max-size=50m \
        -d \
        -p "${service_port}":"${service_port}" \
        -e LANG=C.UTF-8 \
        --network="host" \
        --env IS_DEBUG=True \
        --env-file=../../.env \
        --rm \
        --name "${docker_image_name}" \
        "${docker_image}";
  then
    log_to_stderr 'Error starting container. Exit.'
    exit 1
  else
    log_to_stdout 'Docker container started successfully.'
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
  local script_basename
  script_basename=$(basename "${BASH_SOURCE[0]##*/}")  # don't change
  readonly script_basename

  local project_name
  readonly project_name='notebook'  # enter your project name

  local project_root
  project_root="${HOME}/PycharmProjects/${project_name}"  # change the path if necessary
  readonly project_root

  local docker_image_name
  readonly docker_image_name='boilerplate'  # refers to `${project_root}/src/boilerplate`

  local docker_image_tag
  readonly docker_image_tag='latest'

  local docker_image
  readonly docker_image="${docker_image_name}":"${docker_image_tag}"

  local service_port
  readonly service_port=50000

  # 2. Import bash functions from other scripts.

  # shellcheck source=../common_bash_functions.sh
  source ../common_bash_functions.sh

  # 3. Execution of script logic.
  log_to_stdout "${script_basename}: START SCRIPT EXECUTION"

  docker_pre_cleanup "$@"
  docker_run_container "$@"

  log_to_stdout "${script_basename}: END OF SCRIPT EXECUTION"
}

main "$@"
