#!/bin/bash

##########################################################################################
# Copyright (c) 2022. Viacheslav Kolupaev, https://vkolupaev.com/
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
# file except in compliance with the License. You may obtain a copy of the License at
#
#   https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the specific language governing
# permissions and limitations under the License.
##########################################################################################

##########################################################################################
# The script will create and run the 'boilerplate' application Docker container.
#
# This container is for development purposes only. Do not use this in production!
#
# The container will be named according to the following scheme: <docker_image_name>.
#
# The container is automatically deleted when it is stopped.
#
# The FastAPI web server (Swagger) will be available at: http://127.0.0.1:50000/.
#
# The container has CPU, RAM and swap file limits. If you plan to change the limit
# settings yourself, then make sure you understand what you are doing.
#
# If you need to add or remove some package (dependency) for 'boilerplate', then you
# need to:
# 1. Make changes to the `requirements.txt` file.
# 2. Rebuild the image using the `00_docker_build_local.sh` script.
# 3. Restart container with this script.
#
# If necessary, you need to replace the values of the variables in the `main()` function:
# - `docker_image_name`;
# - `docker_image_tag`;
# - `service_port`; make sure it matches the application config.
#
# The script uses the helper functions from the `common_bash_functions.sh` file.
##########################################################################################


#######################################
# Import library of common bash functions.
# Arguments:
#  None
#######################################
function import_library_of_common_bash_functions() {
  # shellcheck source=../../common_bash_functions.sh
  if ! source ../../common_bash_functions.sh; then
    echo "'common_bash_functions.sh' library was not imported due to some error. Exit."
    exit 1
  else
    log_to_stdout 'The library of common bash functions has been successfully imported. Continue.' 'G'
  fi
}

#######################################
# Run the 'boilerplate' application docker container.
# Arguments:
#   docker_image_name
#   docker_image_tag
#   service_port
#######################################
function docker_run_boilerplate_container() {
  echo ''
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' 'Bl'
  log_to_stdout 'Running a Docker container based on the <name>:<tag> image...'

  # Checking function arguments.
  if [ -z "$1" ] || [ "$1" = '' ] || [[ "$1" = *' '* ]] ; then
    log_to_stderr "Argument 'docker_image_name' was not specified in the function call. Exit."
    exit 1
  else
    local docker_image_name
    docker_image_name=$1
    readonly docker_image_name
    log_to_stdout "Argument 'docker_image_name' = ${docker_image_name}"
  fi

  if [ -z "$2" ] || [ "$2" = '' ] || [[ "$2" = *' '* ]] ; then
    log_to_stderr "Argument 'docker_image_tag' was not specified in the function call. Exit."
    exit 1
  else
    local docker_image_tag
    docker_image_tag=$2
    readonly docker_image_tag
    log_to_stdout "Argument 'docker_image_tag' = ${docker_image_tag}"
  fi

  if [ -z "$3" ] || [ "$3" = '' ] || [[ "$3" = *' '* ]] ; then
    log_to_stderr "Argument 'service_port' was not specified in the function call. Exit."
    exit 1
  else
    local service_port
    service_port=$3
    readonly service_port
    log_to_stdout "Argument 'service_port' = ${service_port}"
  fi

  # Starting an image-based container and executing the specified command in it.
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
        --privileged=false  `# Be careful when enabling this option! Potentially unsafe.
        # The container can then do almost everything that the host can do.` \
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
    log_to_stdout 'Docker container started successfully. Continue.' 'G'
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<' 'Bl'
}

#######################################
# Run the main function of the script.
# Arguments:
#  None
#######################################
function main() {
  # 1. Declaring Local Variables.
  local docker_registry
  readonly docker_registry='docker.io'

  local docker_user_name
  readonly docker_user_name='vkolupaev'

  local docker_image_name
  readonly docker_image_name='boilerplate'  # refers to `${project_root}/src/boilerplate`

  local docker_image_tag
  readonly docker_image_tag='latest'

  local service_port
  readonly service_port=50000

  # 2. Import the library of common bash functions.
  import_library_of_common_bash_functions "$@"

  # 3. Execution of script logic.
  log_to_stdout 'START SCRIPT EXECUTION.' 'Bl'

  # Execute Docker operations.
  check_if_docker_is_running "$@"

  # A login to the registry is needed to try to download a locally missing image.
  docker_login_to_registry \
    "${docker_registry}" \
    "${docker_user_name}"

  docker_stop_and_remove_containers_by_name "${docker_image_name}"
  docker_stop_and_remove_containers_by_ancestor \
    "${docker_image_name}" \
    "${docker_image_tag}"

  docker_create_user_defined_bridge_network "${docker_image_name}"
  docker_run_boilerplate_container \
    "${docker_image_name}" \
    "${docker_image_tag}" \
    "${service_port}"

  log_to_stdout 'END OF SCRIPT EXECUTION.' 'Bl'
}

main "$@"
