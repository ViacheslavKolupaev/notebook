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


function get_is_pkg_installed() {
  return "$(dpkg-query -W -f '${Status}\n' "${1}" 2>&1|awk '/ok installed/{print 0;exit}{print 1}')"
}

function check_packages_and_install_missing() {
  log_to_stdout 'Checking if all required packages are installed and installing missing ones...'
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  local required_pkgs
  # Specify valid package names separated by spaces.
  required_pkgs=(git-lfs)
  readonly required_pkgs

  local missing_pkgs
  missing_pkgs=""

  for pkg in "${required_pkgs[@]}"; do
    if ! get_is_pkg_installed $pkg ; then
      log_to_stdout "Required package '${pkg}' is not installed."
      missing_pkgs+=" $pkg"
    else
      log_to_stdout "The required package '${pkg}' is already installed."
    fi
  done

  if [ ! -z "$missing_pkgs" ]; then
    log_to_stdout 'Missing packages found. Installation is required to continue.'
    log_to_stdout "Command execution: 'sudo apt update && sudo apt install -y ${missing_pkgs}'"

    sudo apt-get update
    if ! sudo apt-get install -y --no-install-recommends ${missing_pkgs}; then
      log_to_stderr "Package installation error: ${missing_pkgs}. Exit."
      exit 1
    else
      sudo apt-get clean autoclean -y && sudo apt-get autoremove -y
      log_to_stdout "Missing packages installed successfully: ${missing_pkgs}."
    fi
  else
    log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
    log_to_stdout 'All required packages are already installed.'
  fi
}

function configure_project() {
  if [ $os_type = 'ubuntu' ]; then
    check_packages_and_install_missing "$@"
  fi

  if ! git lfs install; then
    log_to_stderr 'Error installing Git LFS. Exit.'
    exit 1
  else
    log_to_stdout 'Git LFS installed successfully.'
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
  elif [[ "${OSTYPE}" == 'linux-gnu'* ]]; then
    os_type='ubuntu'
    log_to_stdout 'Detected OS: Linux Ubuntu / WSL. Continue.'
    venv_scripts_dir='bin'
  else
    log_to_stderr 'Detected OS: Unknown. Exit.'
    exit 1
  fi
}

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

  local python_version
  readonly python_version='310'  # specify your Python interpreter version: 39, 310, etc.

  local venv_name
  readonly venv_name="venv_py${python_version}"  # for example: "venv_py310"; provide your venv name, if necessary

  local os_type
  os_type='unknown'  # operating system type to be determined later

  local venv_scripts_dir
  venv_scripts_dir='unknown'  # different on Linux and Windows

  # 2. Execution of script logic.
  log_to_stdout "${script_basename}: START SCRIPT EXECUTION"

  detect_os_type "$@"  # modifies the "os_type" variable
  configure_project "$@"

  log_to_stdout "${script_basename}: END OF SCRIPT EXECUTION"
}

main "$@"
