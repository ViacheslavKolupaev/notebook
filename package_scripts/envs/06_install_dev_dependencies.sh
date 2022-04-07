#!/bin/bash
#
# Install "dev" dependencies into the virtual environment (venv) of the project.
#
# Files with incoming project dependency requirements:
#  - "requirements/in/06_dev.in"
#
# Script compiled (output) project dependency file(s):
#  - "requirements/compiled/06_dev_requirements.txt"
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
# Compile "/requirements/compiled/<req_in_file_name>_requirements.txt".
# Compilation is based on the file "<req_in_file_name>.in".
# Globals:
#   project_root
#   req_in_file_name
#   req_compiled_file_full_path
# Arguments:
#  None
#   Writes progress messages to stdout and error messages to stderr.
# Returns:
#   0 if there are no errors, non-zero on error.
#######################################
function compile_requirements_file() {
  log_to_stdout "Compiling the resulting project dependency file: ${req_compiled_file_full_path}"
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
  if ! pip-compile \
      "${project_root}"/requirements/in/"${req_in_file_name}".in \
      --output-file=- >"${req_compiled_file_full_path}"; then
    log_to_stderr 'Error compiling resulting project dependency file. Exit.'
    exit 1
  else
    log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
    log_to_stdout "The resulting project dependency file was successfully compiled: ${req_compiled_file_full_path}"
  fi
}

#######################################
# Synchronize project dependencies with the specified compiled dependency file(s).
# The following files are being synchronized:
#  - "/requirements/compiled/01_app_requirements.txt"
#  - "/requirements/compiled/02_lint_test_requirements.txt"
#  - "/requirements/compiled/03_type_test_requirements.txt"
#  - "/requirements/compiled/04_unit_test_requirements.txt"
#  - "/requirements/compiled/05_docs_requirements.txt"
#  - "/requirements/compiled/<req_in_file_name>_requirements.txt"
# Globals:
#   project_root
#   req_compiled_file_full_path
# Arguments:
#  None
# Outputs:
#   Writes progress messages to stdout and error messages to stderr.
# Returns:
#   0 if there are no errors, non-zero on error.
#######################################
function sync_dependencies() {
  log_to_stdout "Synchronizing project dependencies with the specified requirements file(s)..."
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  if ! pip-sync \
      "${project_root}/requirements/compiled/01_app_requirements.txt" \
      "${project_root}/requirements/compiled/02_lint_test_requirements.txt" \
      "${project_root}/requirements/compiled/03_type_test_requirements.txt" \
      "${project_root}/requirements/compiled/04_unit_test_requirements.txt" \
      "${project_root}/requirements/compiled/05_docs_requirements.txt" \
      "${req_compiled_file_full_path}"; then
    log_to_stderr 'Error syncing project dependencies. Exit.'
    exit 1
  else
    log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
    log_to_stdout "The project's venv dependencies were successfully synced to the specified requirements file(s)."
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

  local req_in_file_name
  req_in_file_name="06_dev"  # incoming dependency file name
  readonly req_in_file_name

  # Full path where the compiled dependency file will be saved. Requires operating system type.
  local req_compiled_file_full_path
  req_compiled_file_full_path="${project_root}/requirements/compiled/${req_in_file_name}_requirements.txt"
  readonly req_compiled_file_full_path

  local os_type
  os_type='unknown'  # operating system type to be determined later

  local venv_scripts_dir
  venv_scripts_dir='unknown'  # different on Linux and Windows

  # 2. Execution of script logic.
  log_to_stdout "${script_basename}: START SCRIPT EXECUTION"

  detect_os_type "$@"  # modifies the "os_type" variable
  activate_venv "$@"
  compile_requirements_file "$@"
  sync_dependencies "$@"

  log_to_stdout "${script_basename}: END OF SCRIPT EXECUTION"
}

main "$@"
