#!/bin/bash
#
# Install all necessary dependencies, operating system packages and configure the project.
#
# Usually you need to run this script only once at the start of the project.
#
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

#######################################
# Activate the virtual environment (venv).
# Globals:
#   PWD
#   os_type
#   project_root
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

  cd "${project_root}/${venv_name}/${venv_scripts_dir}" || exit 1
  log_to_stdout "Current pwd: ${PWD}"

  if ! source activate; then
    log_to_stderr 'Failed to activate venv. Exit.'
    exit 1
  else
    log_to_stdout "Virtual environment \"${venv_name}\" successfully activated."
  fi
}

#######################################
# Check if the Ubuntu operating system package is installed.
# Arguments:
#   Valid package name.
# Returns:
#   0 if the package is installed on the operating system, 1 otherwise.
#######################################
function get_is_pkg_installed() {
  return "$(dpkg-query -W -f '${Status}\n' "${1}" 2>&1|awk '/ok installed/{print 0;exit}{print 1}')"
}

#######################################
# Check if all necessary packages are installed on the operating system.
# Globals:
#   missing_pkgs
#   required_pkgs
# Arguments:
#  None
#######################################
function check_if_all_required_packages_are_installed() {
  local pkg
  for pkg in "${required_pkgs[@]}"; do
    if ! get_is_pkg_installed "$pkg" ; then
      log_to_stdout "Required package '${pkg}' is not installed. Installation is required to continue."
      missing_pkgs+=" $pkg"
    else
      log_to_stdout "The required package '${pkg}' is already installed."
    fi
  done
}

#######################################
# Install the missing packages on the Ubuntu operating system.
# Globals:
#   missing_pkgs
# Arguments:
#  None
#######################################
function install_missing_packages() {
  if [ -n "$missing_pkgs" ]; then  # if the array is not empty
    log_to_stdout "Command execution: 'sudo apt-get update && sudo apt-get install -y ${missing_pkgs}'"

    sudo apt-get update
    if ! sudo apt-get install -y --no-install-recommends "${missing_pkgs}"; then
      log_to_stderr "Package installation error: ${missing_pkgs}. Exit."
      exit 1
    else
      sudo apt-get clean autoclean -y && sudo apt-get autoremove -y
      log_to_stdout "Missing packages installed successfully: ${missing_pkgs}."
    fi
  else
    log_to_stdout 'All required packages are already installed.'
  fi
}

#######################################
# Install Git LFS.
# Arguments:
#  None
#######################################
function install_git_lfs() {
  if ! git lfs install; then
    log_to_stderr 'Error installing Git LFS. Exit.'
    exit 1
  else
    log_to_stdout 'Git LFS installed successfully.'
  fi
}

#######################################
# Install pre-commit in git hooks.
# Arguments:
#  None
#######################################
function install_pre_commit() {
  if ! pre-commit install; then
    log_to_stderr 'Error installing pre-commit. Exit.'
    exit 1
  else
    log_to_stdout 'pre-commit installed successfully.'
  fi
}

#######################################
# Configure the project.
# Globals:
#   os_type
# Arguments:
#  None
#######################################
function configure_project() {
  if [ $os_type = 'ubuntu' ]; then
    log_to_stdout 'Checking if all required packages are installed and installing missing ones...'
    log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
    check_if_all_required_packages_are_installed "$@"
    install_missing_packages "$@"
    log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
  fi

  install_git_lfs "$@"
  install_pre_commit "$@"
}

#######################################
# Install all project dependencies by running the appropriate scripts.
# Globals:
#   project_root
# Arguments:
#  None
#######################################
function install_all_project_dependencies() {
  # shellcheck source=01_install_app_dependencies.sh
  source "${project_root}"/package_scripts/envs/01_install_app_dependencies.sh

  # shellcheck source=02_install_lint_test_dependencies.sh
  source "${project_root}"/package_scripts/envs/02_install_lint_test_dependencies.sh

  # shellcheck source=03_install_type_test_dependencies.sh
  source "${project_root}"/package_scripts/envs/03_install_type_test_dependencies.sh

  # shellcheck source=04_install_unit_test_dependencies.sh
  source "${project_root}"/package_scripts/envs/04_install_unit_test_dependencies.sh

  # shellcheck source=05_install_docs_dependencies.sh
  source "${project_root}"/package_scripts/envs/05_install_docs_dependencies.sh

  # shellcheck source=06_install_dev_dependencies.sh
  source "${project_root}"/package_scripts/envs/06_install_dev_dependencies.sh
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

  local required_pkgs
  # Specify valid package names separated by spaces.
  required_pkgs=(git-lfs)
  readonly required_pkgs

  local missing_pkgs
  missing_pkgs=""  # don't change

  # 2. Import bash functions from other scripts.
  # shellcheck source=../common_bash_functions.sh
  source ../common_bash_functions.sh

  # 3. Execution of script logic.
  log_to_stdout "${script_basename}: START SCRIPT EXECUTION"

  install_all_project_dependencies "$@"
  detect_os_type "$@"  # modifies the "os_type" variable
  activate_venv "$@"
  configure_project "$@"

  log_to_stdout "${script_basename}: END OF SCRIPT EXECUTION"
}

main "$@"
