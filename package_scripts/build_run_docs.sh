#!/bin/bash
#
# Build the MkDocs documentation & Run the builtin development server.
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
# Build project documentation
# Globals:
#   PWD
#   project_root
# Arguments:
#  None
#######################################
function build_docs() {
  log_to_stdout "Building project documentation..."
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  cd "${project_root}" || exit 1
  log_to_stdout "Current pwd: ${PWD}"

  if ! mkdocs build; then
    log_to_stderr 'Project documentation build error. Exit.'
    exit 1
  else
    log_to_stdout "Project documentation build completed successfully."
    log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
  fi
}

#######################################
# Launch the built-in documentation development server.
# Globals:
#   PWD
#   project_root
# Arguments:
#  None
#######################################
function launch_docs_server() {
  log_to_stdout "Starting the built-in documentation development server..."
  log_to_stdout '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  cd "${project_root}" || exit 1
  log_to_stdout "Current pwd: ${PWD}"

  if ! mkdocs serve; then
    log_to_stderr 'Error starting built-in documentation authoring server. Exit.'
    exit 1
  else
    log_to_stdout "Built-in documentation development server started successfully."
    log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
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

  local os_type
  os_type='unknown'  # operating system type to be determined later

  local venv_scripts_dir
  venv_scripts_dir='unknown'  # different on Linux and Windows

  # 2. Execution of script logic.
  log_to_stdout "${script_basename}: START SCRIPT EXECUTION"

  detect_os_type "$@"  # modifies the "os_type" variable
  activate_venv "$@"
  build_docs "$@"
  launch_docs_server "$@"

  log_to_stdout "${script_basename}: END OF SCRIPT EXECUTION"
}

main "$@"
