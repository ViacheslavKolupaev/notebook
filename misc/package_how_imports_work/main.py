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


"""The main module of the package."""

# The below import will implicitly run the following modules:
#   1. misc/__init__.py
#   2. misc/package_how_imports_work/__init__.py
#   3. misc/package_how_imports_work/subpackage_one/__init__.py
#   4. misc/package_how_imports_work/subpackage_two/__init__.py

# With this approach, subpackage modules must be imported in the __init__.py files of
# those subpackages. Preferred approach.
from misc.package_how_imports_work import subpackage_one, subpackage_two

# With this another approach, subpackage module names must be globally unique.
# Otherwise, there may be path resolution conflicts.
# from misc.package_how_imports_work.subpackage_one import module_one
# from misc.package_how_imports_work.subpackage_two import module_one, module_two

print('\nStarting the main module of the package...')
print(f'9. package: {__package__} | name: {__name__} | file: {__file__}')


def main():
    # Functions.
    print('\nCalling functions from other modules...')
    subpackage_one.module_one.func_sp1_mod1()

    subpackage_two.module_one.func_sp2_mod1()
    subpackage_two.module_two.func_sp2_mod2()

    # Objects.
    print('\nRetrieving objects from other modules...')
    print(f'13. {__name__} | object from another module: {subpackage_one.module_one.var_sp1_mod1}')

    print(f'14. {__name__} | object from another module: {subpackage_two.module_one.var_sp2_mod1}')
    print(f'15. {__name__} | object from another module: {subpackage_two.module_two.var_sp2_mod2}')


if __name__ == "__main__":
    main()
