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
# Stop and remove containers with a name equal to the image name.
# Globals:
#   container_id
#   docker_image_name
# Arguments:
#  None
#######################################
function docker_stop_and_remove_containers_by_name() {
  echo ''
  log_to_stdout 'Stopping and removing containers with a name equal to the image name...'
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  # Get a list of containers with a name equal to the name of the image.
  local container_ids
  container_ids="$(docker ps -aq -f "name=${docker_image_name}")"

  # Stop and remove containers.
  if [[ -n "${container_ids}" ]]; then
    log_to_stdout "Found containers named '${docker_image_name}': ${container_ids}."

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
# Stop and remove containers by ancestor (created from the IMAGE:TAG).
# Globals:
#   container_id
#   docker_image_name
#   docker_image_tag
# Arguments:
#  None
#######################################
function docker_stop_and_remove_containers_by_ancestor() {
  echo ''
  log_to_stdout 'Stopping and removing containers created from the IMAGE:NAME...'
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  # Get a list of containers created based on the specified image.
  local container_ids
  container_ids="$(docker ps -aq -f "ancestor=${docker_image_name}:${docker_image_tag}")"

  # Stop and remove containers.
  if [[ -n "${container_ids}" ]]; then
    log_to_stdout "Containers created from '${docker_image_name}:${docker_image_tag}' image found: ${container_ids}."

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
# Launch a new application Docker container.
# Globals:
#   docker_image_name
#   docker_image_tag
#   service_port
# Arguments:
#  None
#######################################
function docker_run_container() {
  echo ''
  log_to_stdout "Running a Docker container based on the '${docker_image_name}:${docker_image_tag}' image..."
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

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
        --env APP_ENV_STATE="${APP_ENV_STATE}" \
        --env IS_DEBUG="${IS_DEBUG}"  `# Not for production environment.` \
        --env DB_USER="${DB_USER}" \
        --env DB_PASSWORD="${DB_PASSWORD}" \
        --name "${docker_image_name}"  `# Container name.` \
        "${docker_image_name}:${docker_image_tag}"  `# The name and tag of the image to use to launch the container.`;
  then
    log_to_stderr 'Error starting container. Exit.'
    exit 1
  else
    log_to_stdout 'Docker container started successfully. Continue.'
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
  echo ''
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

  local docker_image_name
  readonly docker_image_name='boilerplate'  # refers to `${project_root}/src/boilerplate`

  local docker_image_tag
  readonly docker_image_tag='latest'

  local service_port
  readonly service_port=50000

  local bash_scripts_dir
  readonly bash_scripts_dir=~/PycharmProjects/notebook/airflow/dags/bash_scripts

  # 2. Import bash functions from other scripts.
  source ${bash_scripts_dir}/000_common_bash_functions.sh

  # 3. Execution of script logic.
  log_to_stdout "${script_basename}: START SCRIPT EXECUTION"

  docker_stop_and_remove_containers_by_name "$@"
  docker_stop_and_remove_containers_by_ancestor "$@"
  docker_create_user_defined_bridge_network "${docker_image_name}"
  docker_run_container "$@"

  log_to_stdout "${script_basename}: END OF SCRIPT EXECUTION"
}

main "$@"
