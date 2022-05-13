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
#  Text message.
#######################################
function log_to_stdout() {
  if [ $# -eq 0 ]
  then
    echo "${FUNCNAME[0]}: No arguments supplied. Continue."
  else
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&1
  fi
}

#######################################
# Print an error message to stderr with the date and time.
# Arguments:
#  Text message.
#######################################
function log_to_stderr() {
  if [ $# -eq 0 ]
  then
    echo "${FUNCNAME[0]}: No arguments supplied. Continue."
  else
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  fi
}

#######################################
# Stop the Docker container.
# Globals:
#   FUNCNAME
# Arguments:
#   Docker container ID or name
#######################################
function docker_container_stop() {
  if [ $# -eq 0 ]
  then
    log_to_stderr "${FUNCNAME[0]}: No arguments supplied. Exit."
    exit 1
  else
    local container_id_or_name
    container_id_or_name=$1
    readonly container_id_or_name
  fi

  log_to_stdout "Stopping the '${container_id_or_name}' container..."
  if ! docker stop "${container_id_or_name}"; then
    log_to_stderr "Error stopping container '${container_id_or_name}'. Exit."
    exit 1
  else
    log_to_stdout "Container '${container_id_or_name}' stopped successfully. Continue."
  fi
}

#######################################
# Remove the Docker container.
# Globals:
#   FUNCNAME
# Arguments:
#   Docker container ID or name
#######################################
function docker_container_remove() {
  if [ $# -eq 0 ]
  then
    log_to_stderr "${FUNCNAME[0]}: No arguments supplied. Exit."
    exit 1
  else
    local container_id_or_name
    container_id_or_name=$1
    readonly container_id_or_name
  fi

  log_to_stdout "Removing the '${container_id_or_name}' container..."
  if ! docker rm "${container_id_or_name}"; then
    log_to_stderr "Error removing container '${container_id_or_name}'. Exit."
    exit 1
  else
    log_to_stdout "Container '${container_id_or_name}' removed successfully. Continue."
  fi
}

#######################################
# Remove the Docker image.
# Globals:
#   FUNCNAME
# Arguments:
#   Docker image ID or name
#######################################
function docker_image_remove() {
  if [ $# -eq 0 ]
  then
    log_to_stderr "${FUNCNAME[0]}: No arguments supplied. Exit."
    exit 1
  else
    local image_id_or_name
    image_id_or_name=$1
    readonly image_id_or_name
  fi

  log_to_stdout "Removing the '${image_id_or_name}' image..."
  if ! docker rmi --force "${image_id_or_name}"; then
    log_to_stderr "Error removing image '${image_id_or_name}'. Exit."
    exit 1
  else
    log_to_stdout "Image '${image_id_or_name}' removed successfully. Continue."
  fi
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
  log_to_stdout "Synchronizing the project's virtual environment with the specified requirements files..."
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  if [ -z "$1" ] ; then
    log_to_stderr "${FUNCNAME[0]}: Argument 'req_compiled_file_full_path' was not specified in the function call. Exit."
    exit 1
  else
    local req_compiled_file_full_path
    req_compiled_file_full_path=$1
    readonly req_compiled_file_full_path
    log_to_stdout "Requirements File 1: ${req_compiled_file_full_path}"
  fi

  if [ -n "$2" ] ; then
    local project_root
    project_root=$2
    readonly project_root
    log_to_stdout "Requirements File 2: ${project_root}/requirements/compiled/01_app_requirements.txt"

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
  log_to_stdout "Activating the project's virtual environment..."
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  if [ -z "$1" ] ; then
    log_to_stderr "${FUNCNAME[0]}: Argument 'venv_scripts_dir_full_path' was not specified in the function call. Exit."
    exit 1
  else
    local venv_scripts_dir_full_path
    venv_scripts_dir_full_path=$1
    readonly venv_scripts_dir_full_path
    log_to_stdout "Full path to the virtual environment scripts directory: ${venv_scripts_dir_full_path}"
  fi

  cd "${project_root}/${venv_name}/${venv_scripts_dir}" || exit 1
  cd "${venv_scripts_dir_full_path}" || exit 1
  log_to_stdout "Current pwd: ${PWD}"

  if ! source activate; then
    log_to_stderr 'Virtual environment activation error. Exit.'
    exit 1
  else
    log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
    log_to_stdout 'Virtual environment successfully activated. Continue.'
  fi
}
