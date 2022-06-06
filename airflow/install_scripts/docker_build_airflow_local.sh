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

  local AIRFLOW_VERSION
  readonly AIRFLOW_VERSION="2.2.4"

  local PYTHON_BASE_IMAGE
  readonly PYTHON_BASE_IMAGE="python3.8"

  log_to_stdout 'Changing to the directory with the Dockerfile...'
  cd "${project_root}/airflow/install_scripts" || exit 1
  log_to_stdout "Current pwd: ${PWD}"

  local git_rev_short_sha
  git_rev_short_sha=$(git rev-parse --short HEAD)
  log_to_stdout "git_rev_short_sha: ${git_rev_short_sha}"

  docker rmi --force "dev-apache-airflow:${AIRFLOW_VERSION}-${PYTHON_BASE_IMAGE}"

  # See about DOCKER_BUILDKIT: https://github.com/moby/moby/issues/34151#issuecomment-739018493
  if ! DOCKER_BUILDKIT=1 docker build . \
       --pull \
       --file Dockerfile \
       --build-arg VCS_REF="${git_rev_short_sha}" \
       --build-arg AIRFLOW_VERSION="${AIRFLOW_VERSION}" \
       --build-arg PYTHON_BASE_IMAGE="${PYTHON_BASE_IMAGE}" \
       --tag "dev-apache-airflow:${AIRFLOW_VERSION}-${PYTHON_BASE_IMAGE}"; then
    echo 'Error building Docker image. Exit.'
    exit 1
  else
    echo 'Docker image successfully built. Continue.'
  fi
}

main "$@"
