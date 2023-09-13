# ########################################################################################
#  Copyright (c) 2023. Viacheslav Kolupaev, author's website address:
#
#    https://vkolupaev.com/?utm_source=c&utm_medium=link&utm_campaign=notebook
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

"""Code for implementing task 4.2. from the book 'Grokking Algorithms'."""

from typing import Any


def count_list_elements(list_of_elements: list[Any]) -> int:
    """Count list elements."""
    print('Current `list_of_elements`: {0}'.format(list_of_elements))
    if not list_of_elements:
        return 0
    return 1 + count_list_elements(list_of_elements[1:])


if __name__ == '__main__':
    count_of_list_elements = count_list_elements([1, 3, 5, 7])
    print('Count of list elements: ', count_of_list_elements)
