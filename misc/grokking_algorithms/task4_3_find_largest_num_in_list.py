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

"""Code for implementing task 4.3. from the book 'Grokking Algorithms'."""


def find_largest_num_in_list(list_of_elements: list[int]) -> int:
    """Find the largest number in the list."""
    print('Current `list_of_elements`: {0}'.format(list_of_elements))

    if len(list_of_elements) == 2:
        print('There are 2 elements left in the list. The condition is met.')
        return list_of_elements[0] if list_of_elements[0] > list_of_elements[1] else list_of_elements[1]

    # Call functions recursively until there are 2 elements left in the list.
    sub_max = find_largest_num_in_list(list_of_elements[1:])

    print('=' * 90)
    print('Current `sub_max`: {0}'.format(sub_max))
    print('Current `list_of_elements`: {0}'.format(list_of_elements))

    return list_of_elements[0] if list_of_elements[0] > sub_max else sub_max


if __name__ == '__main__':
    largest_num_in_list = find_largest_num_in_list([1, 10, 3, 9, 7, 4, 2])
    print('=' * 90)
    print('Largest number in the list: ', largest_num_in_list)
