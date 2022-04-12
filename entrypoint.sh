#!/bin/bash
#
# Run the application inside a Docker container.
#
# Copyright 2022 Viacheslav Kolupaev, https://viacheslavkolupaev.ru/
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

  run_python_app "$@"

  log_to_stdout "${script_basename}: END OF SCRIPT EXECUTION"
}

main "$@"
