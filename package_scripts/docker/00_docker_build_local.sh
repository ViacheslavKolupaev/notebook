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

function docker_cleanup() {
  # TODO: finished here; finalize.
  log_to_stdout 'Docker cleanup...'
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  local docker_image_id
  docker_image_id="$(docker images -q "${project_name}":"${docker_image_tag}")"

  local docker_containers_using_image_id
  docker_containers_using_image_id="$(docker ps -q --filter "ancestor=${docker_image_id}")"

  if [[ -n "$docker_image_id" ]]; then
    log_to_stdout "Docker image exists. ID: ${docker_image_id}."
  else
    log_to_stdout "No such Docker image: '${project_name}:${docker_image_tag}'."
  fi

  if [[ -n "$docker_containers_using_image_id" ]]; then
    log_to_stdout "There is a Docker container running from image '${project_name}:${docker_image_tag}'."
  else
    log_to_stdout "There is no Docker container running from '${project_name}:${docker_image_tag}' image."
  fi

  if ! docker stop "$project_name" && docker rm "$project_name"; then
    log_to_stderr 'Error'
    exit 1
  else
    log_to_stdout 'OK'
  fi

  if ! docker rmi "$project_name":"$docker_image_tag"; then
    log_to_stderr 'Error'
    exit 1
  else
    log_to_stdout 'OK'
  fi

  if ! docker image prune --force; then
    log_to_stderr 'Error'
    exit 1
  else
    log_to_stdout 'OK'
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
}

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

  local docker_image_tag
  readonly docker_image_tag='latest'

  # 2. Import bash functions from other scripts.

  # shellcheck source=../common_bash_functions.sh
  source ../common_bash_functions.sh

  # 3. Execution of script logic.
  log_to_stdout "${script_basename}: START SCRIPT EXECUTION"

  cd "${project_root}" || exit 1
  log_to_stdout "Current pwd: ${PWD}"

  docker_cleanup "$@"

  log_to_stdout "${script_basename}: END OF SCRIPT EXECUTION"
}

main "$@"
