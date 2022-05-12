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
# The script will create a Docker image of the application.
#
# Use it for local development and testing.
# The image can be uploaded to a repository such as: DockerHub, Nexus, etc.
#
# If necessary, you need to replace the values of the variables in the `main()` function:
# - `project_name`;
# - `docker_image_name`;
# - `docker_image_tag`.
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
  log_to_stdout 'STEP 1: Docker pre-cleanup...'
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  # Deleting an image by <name>:<tag>.
  if [ "$(docker images -q "${docker_image}")" ]; then
    log_to_stdout "Docker image '${docker_image}' already exists."
    docker_image_remove "${docker_image}"
  else
    log_to_stdout "Docker image '${docker_image}' not found. Continue."
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
}

#######################################
# Build a Docker image using BuildKit.
# Globals:
#   docker_image
#   docker_image_name
# Arguments:
#  None
#######################################
function docker_build_image() {
  log_to_stdout "STEP 2: Building the Docker image of the application: '${docker_image}'..."
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  log_to_stdout 'Changing to the directory with the Dockerfile...'
  cd "${project_root}" || exit 1
  log_to_stdout "Current pwd: ${PWD}"

  # See about DOCKER_BUILDKIT: https://github.com/moby/moby/issues/34151#issuecomment-739018493
  if ! DOCKER_BUILDKIT=1 docker build \
       --build-arg APP_NAME="${docker_image_name}" \
       -t "${docker_image}" .; then
    log_to_stderr 'Error building Docker image. Exit.'
    exit 1
  else
    log_to_stdout 'Docker image successfully built. Continue.'
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

  # 2. Import bash functions from other scripts.
  # shellcheck source=../common_bash_functions.sh
  source ../common_bash_functions.sh

  # 3. Execution of script logic.
  log_to_stdout "${script_basename}: START SCRIPT EXECUTION"

  docker_pre_cleanup "$@"
  docker_build_image "$@"

  log_to_stdout "${script_basename}: END OF SCRIPT EXECUTION"
}

main "$@"
