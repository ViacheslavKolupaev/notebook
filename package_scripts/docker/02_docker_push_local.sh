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
# The script will push the `boilerplate` Docker image to the image registry.
#
# Not suitable for production environment. Use it for local development and testing only!
#
# If necessary, you need to replace the values of the variables in the `main()` function:
# - `docker_registry`;
# - `docker_user_name`;
# - `docker_image_name`;
# - `docker_image_tag`.
#
# Docker Hub: https://hub.docker.com/repository/docker/vkolupaev/boilerplate
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

  local docker_image_name  # refers to the name of the repository in Docker Hub.
  readonly docker_image_name='boilerplate'  # refers to `${project_root}/src/boilerplate`

  local docker_image_tag
  readonly docker_image_tag='latest'

  # 2. Import the library of common bash functions.
  import_library_of_common_bash_functions

  # 3. Execution of script logic.
  log_to_stdout 'START SCRIPT EXECUTION.' 'Bl'

  # Execute Docker operations.
  check_if_docker_is_running
  docker_login_to_registry \
    "${docker_registry}" \
    "${docker_user_name}"

  docker_push_image_to_registry \
    "${docker_registry}" \
    "${docker_user_name}" \
    "${docker_image_name}" \
    "${docker_image_tag}"

  log_to_stdout 'END OF SCRIPT EXECUTION.' 'Bl'
}

main "$@"  # "$@" expands to separate strings - "$1" "$2" "$n"
