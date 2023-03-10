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


import random

# This will be run when the module is imported:
print(f'4. package: {__package__} | name: {__name__} | file: {__file__}')
var_sp1_mod1 = f'value will not change even if imported from several ' \
               f'other modules = {random.randrange(1, 101)}'
print(f'5. package: {__package__} | name: {__name__} | file: {__file__} | {var_sp1_mod1}')


# The functions will NOT run when the module is imported:
def func_sp1_mod1():
    print(f'10. {__name__} | object from this module: {var_sp1_mod1}')
