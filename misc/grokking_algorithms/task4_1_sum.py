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

"""Code for implementing task 4.1. from the book 'Grokking Algorithms'."""


def sum_list_elements(list_of_elements: list[int]) -> int:
    """Sum list elements."""
    print('Current `list_of_elements`: {0}'.format(list_of_elements))
    if not list_of_elements:
        return 0
    return list_of_elements[0] + sum_list_elements(list_of_elements[1:])


if __name__ == '__main__':
    sum_of_list_elements = sum_list_elements([1, 3, 5, 7])
    print('Sum of list elements: ', sum_of_list_elements)
