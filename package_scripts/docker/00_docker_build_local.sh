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
# - `docker_image_tag`.
#
# The script uses the helper functions from the `common_bash_functions.sh` file.
##########################################################################################


#######################################
# Build a Docker image of the `boilerplate` application.
# Arguments:
#  docker_image_name
#  docker_image_tag
#  dockerfile_dir
#######################################
function docker_build_boilerplate_image() {
  echo ''
  log_to_stdout ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  log_to_stdout "Building a standalone Apache Airflow Docker image..."

  # Checking function arguments.
  if [ -z "$1" ] ; then
    log_to_stderr "Argument 'docker_image_name' was not specified in the function call. Exit."
    exit 1
  else
    local docker_image_name
    docker_image_name=$1
    readonly docker_image_name
    log_to_stdout "Argument 'docker_image_name' = ${docker_image_name}"
  fi

  if [ -z "$2" ] ; then
    log_to_stderr "Argument 'docker_image_tag' was not specified in the function call. Exit."
    exit 1
  else
    local docker_image_tag
    docker_image_tag=$2
    readonly docker_image_tag
    log_to_stdout "Argument 'docker_image_tag' = ${docker_image_tag}"
  fi

  if [ -z "$3" ] ; then
    log_to_stderr "Argument 'dockerfile_dir' was not specified in the function call. Exit."
    exit 1
  else
    local dockerfile_dir
    dockerfile_dir=$3
    readonly dockerfile_dir
    log_to_stdout "Argument 'dockerfile_dir' = ${dockerfile_dir}"
  fi

  # Get the short SHA of the current Git revision.
  local git_rev_short_sha
  git_rev_short_sha="$(git rev-parse --short HEAD)"
  log_to_stdout "git_rev_short_sha: ${git_rev_short_sha}"

  # Building a Docker image.
  # See about `DOCKER_BUILDKIT`: https://github.com/moby/moby/issues/34151#issuecomment-739018493
  # See about `DOCKER_SCAN_SUGGEST`: https://github.com/docker/scan-cli-plugin/issues/149#issuecomment-823969364
  if ! DOCKER_BUILDKIT=1 DOCKER_SCAN_SUGGEST=false docker build \
       --pull \
       --file "${dockerfile_dir}/Dockerfile" \
       --build-arg VCS_REF="${git_rev_short_sha}" \
       --build-arg APP_NAME="${docker_image_name}" \
       --tag "${docker_image_name}:${docker_image_tag}" \
       "${dockerfile_dir}"  `# docker context PATH`; then
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

  local docker_image_tag
  readonly docker_image_tag='latest'  # change if necessary

  # 2. Import bash functions from other scripts.
  # shellcheck source=../../common_bash_functions.sh
  source ../../common_bash_functions.sh

  # 3. Execution of script logic.
  log_to_stdout 'START SCRIPT EXECUTION.'

  docker_image_remove_by_name_tag \
    "${docker_image_name}" \
    "${docker_image_tag}"

  docker_build_boilerplate_image \
    "${docker_image_name}" \
    "${docker_image_tag}" \
    "${dockerfile_dir}"

  log_to_stdout 'END OF SCRIPT EXECUTION.'
}

main "$@"
