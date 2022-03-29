#!/bin/bash
#
# Install project initialization dependencies in the virtual environment.
# Generate the first version of the <platform>-<py_ver>-requirements.txt file.
# Shell Style Guide: https://google.github.io/styleguide/shellguide.html

# Copyright 2022 Viacheslav Kolupaev, https://viacheslavkolupaev.ru/

#######################################
# Print out usual message to STDOUT along with other status information.
# Arguments:
#  Message.
#######################################
function log_to_stdout() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&1
}

#######################################
# Print out error message to STDERR along with other status information.
# Arguments:
#  Message.
#######################################
function log_to_stderr() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

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

function install_upgrade_proj_init_dependencies() {
    log_to_stdout 'Installing project initialization dependencies...'
    log_to_stdout '--------------------------------------------------'

    if ! ${pycharm_project_folder}/${venv_name}/${venv_scripts_dir}/python -m pip install --upgrade \
      --requirement ${pycharm_project_folder}/requirements/in/00_proj_init.in; then
      log_to_stderr 'Error installing project initialization dependencies. Exit.'
      exit 1
    else
      log_to_stdout '--------------------------------------------------'
      log_to_stdout 'Project initialization dependencies installed successfully.'
    fi
}

function compile_requirements_file() {
    log_to_stdout 'Compiling the resulting project dependency file...'
    log_to_stdout '--------------------------------------------------'

    if ! pip-compile ${pycharm_project_folder}/requirements/in/00_proj_init.in \
      --output-file=- >${pycharm_project_folder}/${os_type}_py${python_version}_requirements.txt; then
      log_to_stderr 'Error compiling resulting project dependency file. Exit.'
      exit 1
    else
      log_to_stdout '--------------------------------------------------'
      log_to_stdout 'The resulting project dependency file was successfully compiled.'
    fi
}

function sync_dependencies() {
    log_to_stdout 'Project Dependency Synchronization...'
    log_to_stdout '--------------------------------------------------'

    if ! pip-sync ${pycharm_project_folder}/${os_type}_py${python_version}_requirements.txt; then
      log_to_stderr 'Error syncing project dependencies. Exit.'
      exit 1
    else
      log_to_stdout '--------------------------------------------------'
      log_to_stdout 'Project dependencies synced successfully.'
    fi
}

function main() {
  # Declaring Local Variables.
  local project_name
  readonly project_name='notebook'

  local python_version
  readonly python_version='310'

  local venv_name
  readonly venv_name="venv_py${python_version}"

  local script_basename
  script_basename=$(basename ${BASH_SOURCE[0]##*/})
  readonly script_basename

  local pycharm_project_folder
  pycharm_project_folder="${HOME}/PycharmProjects/${project_name}"
  readonly pycharm_project_folder

  local os_type
  os_type='unknown'

  local venv_scripts_dir
  venv_scripts_dir='unknown'


  log_to_stdout "${script_basename}: START"

  # Execution of nested functions.
  detect_os_type "$@"
  install_upgrade_proj_init_dependencies "$@"
  compile_requirements_file "$@"
  sync_dependencies "$@"

  log_to_stdout "${script_basename}: END"
}

main "$@"
