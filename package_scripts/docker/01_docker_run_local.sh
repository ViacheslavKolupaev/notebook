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
# The script will create a Docker image of the application.
#
# Use it for local development and testing.
# The image can be uploaded to a repository such as: DockerHub, Nexus, etc.
#
# If necessary, you need to replace the values of the variables in the `main()` function:
# - project_name
# - docker_image_name
# - docker_image_tag.
##########################################################################################

#######################################
# Delete the Docker image before creating an image with the same name and tag.
# Globals:
#   container_id
#   docker_image
# Arguments:
#  None
#######################################
function docker_pre_cleanup() {
  log_to_stdout 'Docker pre-cleanup...'
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  docker stop "${docker_image_name}" && docker rm "${docker_image_name}"

  # Getting a list of containers created based on the image ID.
  local docker_containers_using_image_id
  docker_containers_using_image_id="$(docker ps -a -q --filter "ancestor=${docker_image}")"

  # Removing containers created from the image.
  if [[ -n "${docker_containers_using_image_id}" ]]; then
    log_to_stdout "Containers created from '${docker_image}' image found: ${docker_containers_using_image_id}."
    for container_id in "${docker_containers_using_image_id[@]}"; do
      if ! (docker stop "${container_id}" && docker rm "${container_id}"); then
        log_to_stderr "Error deleting Docker container with ID '${container_id}'."
        exit 1
      else
        log_to_stdout "Docker container with ID '${container_id}' was successfully deleted."
      fi
    done
  else
    log_to_stdout "There is no Docker container running from '${docker_image}' image."
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
}

function docker_run_container() {
  log_to_stdout "Running a Docker container based on the '${docker_image}' image..."
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
