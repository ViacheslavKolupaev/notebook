# ########################################################################################
#  Copyright (c) 2023. Viacheslav Kolupaev, https://vkolupaev.com/
#
#  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
#  file except in compliance with the License. You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software distributed under
#  the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
#  ANY KIND, either express or implied. See the License for the specific language
#  governing permissions and limitations under the License.
# ########################################################################################


"""The `__init__.py` file of the regular Python package.

A regular package is typically implemented as a directory containing an __init__.py file.

When a regular package is imported, this __init__.py file is implicitly executed, and the
objects it defines are bound to names in the package’s namespace.

Docs: https://docs.python.org/3/reference/import.html#regular-packages
"""

# This will be run when the module is imported:
print('\nModule imports before the start of the main function...')
print(f'1. package: {__package__} | name: {__name__} | file: {__file__}')
