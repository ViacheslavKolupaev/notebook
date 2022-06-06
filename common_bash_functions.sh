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
# The script provides common bash functions.
#
# To use it, import it into your script with the `source` command.
##########################################################################################


#######################################
# Print a message to stdout with the date and time.
# Globals:
#   FUNCNAME
# Arguments:
#  text_message
#######################################
function log_to_stdout() {
  if [ -z "$1" ] ; then
    echo "${FUNCNAME[0]}: Argument 'text_message' was not specified in the function call. Continue."
  else
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&1
  fi
}

#######################################
# Print an error message to stderr with the date and time.
# Arguments:
#  text_message
#######################################
function log_to_stderr() {
  if [ -z "$1" ] ; then
    echo "${FUNCNAME[0]}: Argument 'text_message' was not specified in the function call. Continue."
  else
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  fi
}

#######################################
# Stop the Docker container.
# Globals:
#   FUNCNAME
# Arguments:
#   container_id_or_name
#######################################
function docker_container_stop() {
  echo ''
  if [ -z "$1" ] ; then
    log_to_stderr "${FUNCNAME[0]}: Argument 'container_id_or_name' was not specified in the function call. Exit."
    exit 1
  else
    local container_id_or_name
    container_id_or_name=$1
    readonly container_id_or_name
    log_to_stdout "${FUNCNAME[0]}: container_id_or_name = ${container_id_or_name}"
  fi

  log_to_stdout "Stopping the '${container_id_or_name}' container..."
  if ! docker stop "${container_id_or_name}"; then
    log_to_stderr "Error stopping container '${container_id_or_name}'. Exit."
    exit 1
  else
    log_to_stdout "Container '${container_id_or_name}' stopped successfully. Continue."
  fi
  echo ''
}

#######################################
# Remove the Docker container.
# Globals:
#   FUNCNAME
# Arguments:
#   container_id_or_name
#######################################
function docker_container_remove() {
  echo ''
  if [ -z "$1" ] ; then
    log_to_stderr "${FUNCNAME[0]}: Argument 'container_id_or_name' was not specified in the function call. Exit."
    exit 1
  else
    local container_id_or_name
    container_id_or_name=$1
    readonly container_id_or_name
    log_to_stdout "${FUNCNAME[0]}: container_id_or_name = ${container_id_or_name}"
  fi

  log_to_stdout "Removing the '${container_id_or_name}' container..."
  if ! docker rm "${container_id_or_name}"; then
    log_to_stderr "Error removing container '${container_id_or_name}'. Exit."
    exit 1
  else
    log_to_stdout "Container '${container_id_or_name}' removed successfully. Continue."
  fi
  echo ''
}

#######################################
# Remove the Docker image.
# Globals:
#   FUNCNAME
# Arguments:
#   image_id_or_name
#######################################
function docker_image_remove() {
  echo ''
  if [ -z "$1" ] ; then
    log_to_stderr "${FUNCNAME[0]}: Argument 'image_id_or_name' was not specified in the function call. Exit."
    exit 1
  else
    local image_id_or_name
    image_id_or_name=$1
    readonly image_id_or_name
    log_to_stdout "${FUNCNAME[0]}: image_id_or_name = ${image_id_or_name}"
  fi

  log_to_stdout "Removing the '${image_id_or_name}' image..."
  if ! docker rmi --force "${image_id_or_name}"; then
    log_to_stderr "Error removing image '${image_id_or_name}'. Exit."
    exit 1
  else
    log_to_stdout "Image '${image_id_or_name}' removed successfully. Continue."
  fi
  echo ''
}

#######################################
# Remove the Docker image by <name>:<tag>.
#
# Useful before creating an image with the same name and tag.
# Globals:
#   FUNCNAME
# Arguments:
#   docker_image_name
#   docker_image_tag
#######################################
function docker_image_remove_by_name_tag(){
  echo ''
  log_to_stdout 'Removing Docker image by <name>:<tag>...'
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

  # Removing an image by <name>:<tag>.
  if [ "$(docker images -q "${docker_image_name}:${docker_image_tag}")" ]; then
    log_to_stdout "Docker image '${docker_image_name}:${docker_image_tag}' already exists."
    docker_image_remove "${docker_image_name}:${docker_image_tag}"
  else
    log_to_stdout "Docker image '${docker_image_name}:${docker_image_tag}' not found. Continue."
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
  echo ''
}

#######################################
# Stop and remove containers with a name equal to the image name.
# Globals:
#   FUNCNAME
# Arguments:
#  docker_image_name
#######################################
function docker_stop_and_remove_containers_by_name() {
  echo ''
  log_to_stdout 'Stopping and removing containers with a name equal to the image name...'
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

  # Get a list of containers with a name equal to the name of the image.
  local container_ids
  container_ids="$(docker ps -aq -f "name=${docker_image_name}")"

  # Stop and remove containers.
  if [[ -n "${container_ids}" ]]; then
    log_to_stdout "Found containers named '${docker_image_name}': ${container_ids}."

    local container_id
    for container_id in "${container_ids[@]}"; do
      docker_container_stop "${container_id}"
      if [ "$(docker ps -aq -f status=exited -f id="${container_id}")" ]; then
          docker_container_remove "${container_id}"
      fi
    done
  else
    log_to_stdout "There are no containers named '${docker_image_name}'. Continue."
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
  echo ''
}

#######################################
# Stop and remove containers by ancestor (created from the <name>:<tag>).
# Globals:
#   FUNCNAME
# Arguments:
#  docker_image_name
#  docker_image_tag
#######################################
function docker_stop_and_remove_containers_by_ancestor() {
  echo ''
  log_to_stdout 'Stopping and removing containers created from the <name>:<tag>...'
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

  # Get a list of containers created based on the specified image.
  local container_ids
  container_ids="$(docker ps -aq -f "ancestor=${docker_image_name}:${docker_image_tag}")"

  # Stop and remove containers.
  if [[ -n "${container_ids}" ]]; then
    log_to_stdout "Containers created from '${docker_image_name}:${docker_image_tag}' image found: ${container_ids}."

    local container_id
    for container_id in "${container_ids[@]}"; do
      docker_container_stop "${container_id}"
      if [ "$(docker ps -aq -f status=exited -f id="${container_id}")" ]; then
          docker_container_remove "${container_id}"
      fi
    done
  else
    log_to_stdout "There are no containers running from the '${docker_image_name}:${docker_image_tag}' image. Continue."
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
  echo ''
}

#######################################
# Create user-defined bridge network with name '<docker_image_name>-net'.
# Globals:
#   FUNCNAME
# Arguments:
#   docker_image_name
#######################################
function docker_create_user_defined_bridge_network() {
  echo ''
  log_to_stdout 'Creating user-defined bridge network...'
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

  if [ "$(docker network ls -q -f "name=${docker_image_name}-net")" ]; then
    log_to_stdout "Docker network '${docker_image_name}-net' already exists. Continue."
  else
    if ! docker network create --driver bridge "${docker_image_name}"-net; then
      log_to_stderr 'Error creating user-defined bridge network. Exit.'
      exit 1
    else
      log_to_stdout "The user-defined bridge network '${docker_image_name}-net' has been created. Continue."
    fi
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
  echo ''
}

#######################################
# Synchronize the project's virtual environment with the specified requirements files.
# Globals:
#   FUNCNAME
# Arguments:
#   The full path to the compiled dependency file, with which to sync. Required.
#   Path to the root of the project. Optional. If specified, will additionally sync with `01_app_requirements.txt`.
#######################################
function sync_venv_with_specified_requirements_files() {
  echo ''
  log_to_stdout "Synchronizing the project's virtual environment with the specified requirements files..."
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  if [ -z "$1" ] ; then
    log_to_stderr "${FUNCNAME[0]}: Argument 'req_compiled_file_full_path' was not specified in the function call. Exit."
    exit 1
  else
    local req_compiled_file_full_path
    req_compiled_file_full_path=$1
    readonly req_compiled_file_full_path
    log_to_stdout "${FUNCNAME[0]}: requirements file 1 = ${req_compiled_file_full_path}"
  fi

  if [ -n "$2" ] ; then
    local project_root
    project_root=$2
    readonly project_root
    log_to_stdout "${FUNCNAME[0]}: requirements file 2: ${project_root}/requirements/compiled/01_app_requirements.txt"

    if ! pip-sync \
        "${project_root}/requirements/compiled/01_app_requirements.txt" \
        "${req_compiled_file_full_path}"; then
      log_to_stderr 'Virtual environment synchronization error. Exit.'
      exit 1
    fi

  else

    if ! pip-sync "${req_compiled_file_full_path}"; then
      log_to_stderr 'Virtual environment synchronization error. Exit.'
      exit 1
    fi

  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
  log_to_stdout "The project virtual environment was successfully synchronized with the specified requirements files."
  echo ''
}

#######################################
# Activate the project's virtual environment.
# Globals:
#   FUNCNAME
#   PWD
# Arguments:
#   Full path to the virtual environment scripts directory (depends on OS type)
#######################################
function activate_virtual_environment() {
  echo ''
  log_to_stdout "Activating the project's virtual environment..."
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  if [ -z "$1" ] ; then
    log_to_stderr "${FUNCNAME[0]}: Argument 'venv_scripts_dir_full_path' was not specified in the function call. Exit."
    exit 1
  else
    local venv_scripts_dir_full_path
    venv_scripts_dir_full_path=$1
    readonly venv_scripts_dir_full_path
    log_to_stdout "${FUNCNAME[0]}: venv_scripts_dir_full_path = ${venv_scripts_dir_full_path}"
  fi

  cd "${venv_scripts_dir_full_path}" || exit 1
  log_to_stdout "${FUNCNAME[0]}: current pwd = ${PWD}"

  if ! source activate; then
    log_to_stderr 'Virtual environment activation error. Exit.'
    exit 1
  else
    log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
    log_to_stdout 'Virtual environment successfully activated. Continue.'
    echo ''
  fi
}
