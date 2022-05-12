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

#######################################
# Print a message to stdout with the date and time.
# Arguments:
#  Text message.
#######################################
function log_to_stdout() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&1
}

#######################################
# Print an error message to stderr with the date and time.
# Arguments:
#  Text message.
#######################################
function log_to_stderr() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

#######################################
# Stop the Docker container.
# Arguments:
#   Docker container ID or name
#######################################
function docker_container_stop() {
  local container_id_or_name
  container_id_or_name=$1

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
# Arguments:
#   Docker container ID or name
#######################################
function docker_container_remove() {
  local container_id_or_name
  container_id_or_name=$1

  log_to_stdout "Removing the '${container_id_or_name}' container..."
  if ! docker rm "${container_id_or_name}"; then
    log_to_stderr "Error removing container '${container_id_or_name}'. Exit."
    exit 1
  else
    log_to_stdout "Container '${container_id_or_name}' removed successfully. Continue."
  fi
}

#######################################
# description
# Arguments:
#   Docker image ID or name
#######################################
function docker_image_remove() {
  local image_id_or_name
  image_id_or_name=$1

  log_to_stdout "Removing the '${image_id_or_name}' image..."
  if ! docker rmi --force "${image_id_or_name}"; then
    log_to_stderr "Error removing image '${image_id_or_name}'. Exit."
    exit 1
  else
    log_to_stdout "Image '${image_id_or_name}' removed successfully. Continue."
  fi
}
