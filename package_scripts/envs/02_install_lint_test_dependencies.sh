#!/bin/bash
#
# Install "lint_test" dependencies into the virtual environment (venv) of the project.
#
# Files with incoming project dependency requirements:
#  - "requirements/in/02_lint_test.in"
#
# Script generated (output) project dependency file(s):
#  - "requirements/generated/02_lint_test_requirements_<os_type>_py<python_version>.txt"
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
# Activate the virtual environment (venv).
# Globals:
#   PWD
#   os_type
#   pycharm_project_folder
#   venv_name
#   venv_scripts_dir
# Arguments:
#  None
#   Writes progress messages to stdout and error messages to stderr.
# Returns:
#   0 if there are no errors, non-zero on error.
#######################################
function activate_venv() {
  log_to_stdout "Activating a virtual environment on the \"${os_type}\" platform..."

  cd "${pycharm_project_folder}/${venv_name}/${venv_scripts_dir}" || exit 1
  log_to_stdout "Current pwd: ${PWD}"

  if ! source activate; then
    log_to_stderr 'Failed to activate venv. Exit.'
    exit 1
  else
    log_to_stdout "Virtual environment \"${venv_name}\" successfully activated."
  fi
}

#######################################
# Determine the type of operating system to specify the correct path to the venv scripts folder.
# The current version is designed for the following platforms only (others can be added as needed):
#   - "msys": MSYS / Git Bash for Windows;
#   - "linux-gnu": Linux Ubuntu / WSL.
# Globals:
#   OSTYPE
#   os_type
#   venv_scripts_dir
# Arguments:
#  None
#   Writes progress messages to stdout and error messages to stderr.
# Returns:
#   0 if there are no errors, non-zero on error.
#######################################
function detect_os_type() {
  if [[ "${OSTYPE}" == 'msys' ]]; then
    os_type='windows'
    log_to_stdout 'Detected OS: MSYS / Git Bash for Windows. Continue.'
    venv_scripts_dir='Scripts'
    activate_venv "$@"
  elif [[ "${OSTYPE}" == 'linux-gnu'* ]]; then
    os_type='ubuntu'
    log_to_stdout 'Detected OS: Linux Ubuntu / WSL. Continue.'
    venv_scripts_dir='bin'
    activate_venv "$@"
  else
    log_to_stderr 'Detected OS: Unknown. Exit.'
    exit 1
  fi
}

#######################################
# Compile "<req_file_name>_requirements_<os_type>_py<python_version>.txt".
# Compilation is based on the file "<req_file_name>.in".
# Globals:
#   os_type
#   pycharm_project_folder
#   python_version
#   req_file_name
#   req_file_full_path
# Arguments:
#  None
#   Writes progress messages to stdout and error messages to stderr.
# Returns:
#   0 if there are no errors, non-zero on error.
#######################################
function compile_requirements_file() {
  log_to_stdout "Compiling the resulting project dependency file: ${req_file_full_path}"
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
  if ! pip-compile "${pycharm_project_folder}"/requirements/in/"${req_file_name}".in \
    --output-file=- >"${req_file_full_path}"; then
    log_to_stderr 'Error compiling resulting project dependency file. Exit.'
    exit 1
  else
    log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
    log_to_stdout "The resulting project dependency file was successfully compiled: ${req_file_full_path}"
  fi
}

#######################################
# Synchronize project dependencies with the specified compiled dependency files.
# The following files are being synchronized:
#  - "/01_app_requirements_<os_type>_py<python_version>.txt"
#  - "/requirements/generated/<req_file_name>_requirements_<os_type>_py<python_version>.txt"
# Globals:
#   os_type
#   pycharm_project_folder
#   python_version
#   req_file_name
# Arguments:
#  None
# Outputs:
#   Writes progress messages to stdout and error messages to stderr.
# Returns:
#   0 if there are no errors, non-zero on error.
#######################################
function sync_dependencies() {
  local req_file_01_app_full_path
  req_file_01_app_full_path="${pycharm_project_folder}/01_app_requirements_${os_type}_py${python_version}.txt"
  readonly req_file_01_app_full_path

  log_to_stdout "Synchronizing the project's venv with the generated dependency file: ${req_file_full_path}"
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  if ! pip-sync "${req_file_01_app_full_path}" "${req_file_full_path}"; then
    log_to_stderr 'Error syncing project dependencies. Exit.'
    exit 1
  else
    log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
    log_to_stdout "The project venv was successfully synchronized with the dependency file: ${req_file_full_path}"
  fi
}

#######################################
# Run the main function of the script.
# Globals:
#   BASH_SOURCE
#   HOME
# Arguments:
#  None
#######################################
function main() {
  # Declaring Local Variables.
  local project_name
  readonly project_name='notebook'

  local python_version
  readonly python_version='310'

  local venv_name
  readonly venv_name="venv_py${python_version}"

  local script_basename
  script_basename=$(basename "${BASH_SOURCE[0]##*/}")
  readonly script_basename

  local pycharm_project_folder
  pycharm_project_folder="${HOME}/PycharmProjects/${project_name}"
  readonly pycharm_project_folder

  local req_file_name
  req_file_name="02_lint_test"
  readonly req_file_name

  local os_type
  os_type='unknown'

  local venv_scripts_dir
  venv_scripts_dir='unknown'


  log_to_stdout "${script_basename}: START SCRIPT EXECUTION"

  # Execution of nested functions.
  detect_os_type "$@"

  local req_file_full_path
  local req_file_full_path="${pycharm_project_folder}/requirements/generated/"
  req_file_full_path+="${req_file_name}_requirements_${os_type}_py${python_version}.txt"
  readonly req_file_full_path

  compile_requirements_file "$@"
  sync_dependencies "$@"

  log_to_stdout "${script_basename}: END OF SCRIPT EXECUTION"
}

main "$@"
