#!/bin/bash

#
# Copyright (c) 2022. Viacheslav Kolupaev, https://vkolupaev.com/
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
# Run a Python application inside a Docker container.
# Arguments:
#  None
#######################################
function run_python_app() {
  log_to_stdout "Running a Python application inside a Docker container..."

  if ! python3 "src/boilerplate/server.py"; then
    log_to_stderr "Error starting Python application."
    exit 1
  else
    log_to_stdout "Python application started successfully."
  fi
}

#######################################
# Run the main function of the script.
# Globals:
#   BASH_SOURCE
# Arguments:
#  None
#######################################
function main() {
  # 1. Declaring Local Variables.
  local script_basename
  script_basename=$(basename "${BASH_SOURCE[0]##*/}") # don't change
  readonly script_basename

  # 2. Execution of script logic.
  log_to_stdout "${script_basename}: START SCRIPT EXECUTION"

  sleep 30
  run_python_app "$@"

  log_to_stdout "${script_basename}: END OF SCRIPT EXECUTION"
}

main "$@"
