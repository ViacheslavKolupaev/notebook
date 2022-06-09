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
# The script will push the Docker image to a private registry.
#
# Use it for local development and testing.
#
# If necessary, you need to replace the values of the variables in the `main()` function:
# - `docker_registry`;
# - `docker_user_name`;
# - `docker_image_name`;
# - `docker_image_tag`.
#
# Docker Hub: https://hub.docker.com/repository/docker/vkolupaev/boilerplate
##########################################################################################


#######################################
# Login to the private registry of Docker images.
# Globals:
#   docker_registry
# Arguments:
#  None
#######################################
function docker_login_to_registry() {
  log_to_stdout "STEP 1: Login to the private registry of Docker images: '${docker_registry}/${docker_user_name}'."
  log_to_stdout 'Use an account or token with read and write permissions to the registry.'
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  if ! docker login -u "${docker_user_name}" "${docker_registry}/${docker_user_name}"; then
    log_to_stderr 'Login failed. Exit.'
    exit 1
  else
    log_to_stdout 'Login succeeded. Continue'.
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
}

#######################################
# Push a Docker image to a private registry.
# Globals:
#   docker_image_name
#   docker_image_tag
#   docker_registry
# Arguments:
#  None
#######################################
function docker_push_image_to_registry() {
  log_to_stdout 'STEP 2: Push a Docker image to a private registry...'
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  # Tag an image for a private repository.
  log_to_stdout 'Tagging...'
  # docker tag local-image:tagname new-repo:tagname
  if ! docker tag \
       "${docker_image_name}:${docker_image_tag}" \
       "${docker_registry}/${docker_user_name}/${docker_image_name}:${docker_image_tag}"; then
    log_to_stderr 'Tag failed. Exit'.
    exit 1
  else
    log_to_stdout 'Tag succeeded. Continue'.
  fi

  # Push the image to the registry.
  log_to_stdout 'Pushing...'
  if ! docker push \
       "${docker_registry}/${docker_user_name}/${docker_image_name}:${docker_image_tag}"; then
    log_to_stderr 'Push failed. Exit.'
    exit 1
  else
    log_to_stdout 'Push succeeded. Continue'.
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
}

#######################################
# Run the main function of the script.
# Globals:
#   BASH_SOURCE
# Arguments:
#  None
#######################################
function main() {
  # 1. Declaring Local Variables.
  local docker_registry
  readonly docker_registry='docker.io'

  local docker_user_name
  readonly docker_user_name='vkolupaev'

  local docker_image_name  # refers to the name of the repository in Docker Hub.
  readonly docker_image_name='boilerplate'  # refers to `${project_root}/src/boilerplate`

  local docker_image_tag
  readonly docker_image_tag='latest'

  # 2. Import bash functions from other scripts.

  # shellcheck source=../../common_bash_functions.sh
  source ../../common_bash_functions.sh

  # 3. Execution of script logic.
  log_to_stdout 'START SCRIPT EXECUTION.'

  docker_login_to_registry "$@"
  docker_push_image_to_registry "$@"

  log_to_stdout 'START SCRIPT EXECUTION.'
}

main "$@"
