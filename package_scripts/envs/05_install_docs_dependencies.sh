#!/bin/bash
#
#  Copyright (c) 2022. Viacheslav Kolupaev, https://vkolupaev.com/
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       https://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

##########################################################################################
# Install "docs" dependencies into the virtual environment (venv) of the project.
#
# Files with incoming project dependency requirements:
#  - "requirements/in/05_docs.in"
#
# Script compiled (output) project dependency file(s):
#  - "requirements/compiled/05_docs_requirements.txt"
##########################################################################################


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
# Compile "/requirements/compiled/<req_in_file_name>_requirements_<os_type>_py<python_version>.txt".
# Compilation is based on the following dependency files:
#  - "/requirements/in/01_app.in"
#  - "/requirements/in/<req_in_file_name>.in"
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
      "${project_root}"/requirements/in/01_app.in `# All base project dependencies are required.` \
      "${project_root}"/requirements/in/"${req_in_file_name}".in `# Dependencies specific to autodocumentation.` \
      --output-file=- >"${req_compiled_file_full_path}"; then
    log_to_stderr 'Error compiling resulting project dependency file. Exit.'
    exit 1
  else
    log_to_stdout '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
    log_to_stdout "The resulting project dependency file was successfully compiled: ${req_compiled_file_full_path}"
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
  req_in_file_name="05_docs"  # incoming dependency file name
  readonly req_in_file_name

  # Full path where the compiled dependency file will be saved. Requires operating system type.
  local req_compiled_file_full_path
  req_compiled_file_full_path="${project_root}/requirements/compiled/${req_in_file_name}_requirements.txt"
  readonly req_compiled_file_full_path

  local os_type
  os_type='unknown'  # operating system type to be determined later

  local venv_scripts_dir
  venv_scripts_dir='unknown'  # different on Linux and Windows

  # 2. Import bash functions from other scripts.
  # shellcheck source=../../common_bash_functions.sh
  source ../../common_bash_functions.sh

  # 3. Execution of script logic.
  log_to_stdout 'START SCRIPT EXECUTION.'

  detect_os_type "$@"  # modifies the "os_type" variable
  activate_virtual_environment "${project_root}/${venv_name}/${venv_scripts_dir}"
  compile_requirements_file "$@"
  sync_venv_with_specified_requirements_files "${req_compiled_file_full_path}" "${project_root}"

  log_to_stdout 'END OF SCRIPT EXECUTION.'
}

main "$@"
