#!/bin/bash

# ########################################################################################
#  Copyright (c) 2022 Viacheslav Kolupaev; author's website address:
#
#      https://vkolupaev.com/?utm_source=c&utm_medium=link&utm_campaign=notebook
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# ########################################################################################

##########################################################################################
# The script will build a Docker image of the `boilerplate` application.
#
# Not suitable for production environment. Use it for local development and testing only!
#
# The image will be named according to the following scheme:
# `<docker_image_name>-<docker_image_tag>`.
#
# The image can be uploaded to a repository such as: DockerHub, Nexus, etc.
#
# If necessary, you need to replace the values of the variables in the `main()` function:
# - `dockerfile_dir`;
# - `docker_image_name`;
# - `docker_image_tag`;
# - `python_image_tag`.
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
# Build a Docker image of the `boilerplate` application.
# Arguments:
#  docker_image_name
#  docker_image_tag
#  dockerfile_dir
#  python_image_tag
#######################################
function docker_build_boilerplate_image() {
  echo ''
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' 'Bl'
  log_to_stdout "Building a 'boilerplate' Docker image..."

  # Checking function arguments.
  if [ -z "$1" ] || [ "$1" = '' ] || [[ "$1" = *' '* ]] ; then
    log_to_stderr "Argument 'dockerfile_dir' was not specified in the function call. Exit."
    exit 1
  else
    local dockerfile_dir
    dockerfile_dir=$1
    readonly dockerfile_dir
    log_to_stdout "Argument 'dockerfile_dir' = ${dockerfile_dir}" 'Y'
  fi

  if [ -z "$2" ] || [ "$2" = '' ] || [[ "$2" = *' '* ]] ; then
    log_to_stderr "Argument 'docker_image_name' was not specified in the function call. Exit."
    exit 1
  else
    local docker_image_name
    docker_image_name=$2
    readonly docker_image_name
    log_to_stdout "Argument 'docker_image_name' = ${docker_image_name}" 'Y'
  fi

  if [ -z "$3" ] || [ "$3" = '' ] || [[ "$3" = *' '* ]] ; then
    log_to_stderr "Argument 'docker_image_tag' was not specified in the function call. Exit."
    exit 1
  else
    local docker_image_tag
    docker_image_tag=$3
    readonly docker_image_tag
    log_to_stdout "Argument 'docker_image_tag' = ${docker_image_tag}" 'Y'
  fi

  if [ -z "$4" ] || [ "$4" = '' ] || [[ "$4" = *' '* ]] ; then
    log_to_stderr "Argument 'python_image_tag' was not specified in the function call. Exit."
    exit 1
  else
    local python_image_tag
    python_image_tag=$4
    readonly python_image_tag
    log_to_stdout "Argument 'python_image_tag' = ${python_image_tag}" 'Y'
  fi

  # Get the short SHA of the current Git revision.
  local git_rev_short_sha
  git_rev_short_sha="$(git -C ${dockerfile_dir} rev-parse --short HEAD)"
  readonly git_rev_short_sha
  log_to_stdout "git_rev_short_sha: ${git_rev_short_sha}" 'Y'

  # Building a Docker image.
  # See about `DOCKER_BUILDKIT`: https://github.com/moby/moby/issues/34151#issuecomment-739018493
  # See about `DOCKER_SCAN_SUGGEST`: https://github.com/docker/scan-cli-plugin/issues/149#issuecomment-823969364
  if ! DOCKER_BUILDKIT=1 DOCKER_SCAN_SUGGEST=false docker build \
       --progress=plain \
       --file "${dockerfile_dir}/Dockerfile" \
       --build-arg PYTHON_IMAGE_TAG="${python_image_tag}" \
       --build-arg VCS_REF="${git_rev_short_sha}" \
       --build-arg APP_NAME="${docker_image_name}" \
       --tag "${docker_image_name}:${docker_image_tag}" \
       "${dockerfile_dir}"  `# docker context PATH`; then
    log_to_stderr 'Error building Docker image. Exit.'
    exit 1
  else
    log_to_stdout 'Docker image successfully built. Continue.' 'G'
  fi

  log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<' 'Bl'
}

#######################################
# Run the main function of the script.
# Globals:
#   HOME
# Arguments:
#  None
#######################################
function main() {
  # 1. Declaring Local Variables.
  local dockerfile_dir
  dockerfile_dir="${HOME}/PycharmProjects/notebook/"  # double-check the path
  readonly dockerfile_dir

  local docker_image_name
  readonly docker_image_name='boilerplate'  # change if necessary

  # Get the current branch tag in Git.
  local docker_image_tag
  docker_image_tag="$(git -C ${dockerfile_dir} describe --tags --abbrev=0)"
  readonly docker_image_tag

  local python_image_tag
  readonly python_image_tag='3.10.6-slim'  # change if necessary

  # 2. Import the library of common bash functions.
  import_library_of_common_bash_functions

  # 3. Execution of script logic.
  log_to_stdout 'START SCRIPT EXECUTION.' 'Bl'

  # Execute Docker operations.
  check_if_docker_is_running
  docker_image_remove_by_name_tag \
    "${docker_image_name}" \
    "${docker_image_tag}"

  docker_build_boilerplate_image \
    "${dockerfile_dir}" \
    "${docker_image_name}" \
    "${docker_image_tag}" \
    "${python_image_tag}"


  log_to_stdout 'END OF SCRIPT EXECUTION.' 'Bl'
}

main "$@"  # "$@" expands to separate strings - "$1" "$2" "$n"
