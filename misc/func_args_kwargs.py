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

"""A collection of function call examples with different ways of specifying arguments."""


def print_args_types_values(regular_kwarg: int = 42, *args, **kwargs):
    """Print the types and values of the arguments."""
    print('Type regular_kwarg: ', type(regular_kwarg))
    print('regular_kwarg: ', regular_kwarg)
    print('Type args: ', type(args))
    print('args: ', args)
    print('Type kwargs: ', type(kwargs))
    print('kwargs: ', kwargs)


args: tuple = (1, 2, 3, 4, 5)
kwargs: dict[str, int] = {
    'kwarg1': 1,
    'kwarg2': 2,
    'kwarg3': 3,
}

##########################################################################################
# Scenario 1.
##########################################################################################
print_args_types_values(*args, **kwargs)

# Output:
# Type regular_kwarg:  <class 'int'>
# regular_kwarg:  1
# Type args:  <class 'tuple'>
# args:  (2, 3, 4, 5)
# Type kwargs:  <class 'dict'>
# kwargs:  {'kwarg1': 1, 'kwarg2': 2, 'kwarg3': 3}


##########################################################################################
# Scenario 2.
##########################################################################################
print_args_types_values(regular_kwarg=999, *args, **kwargs)

# WPS: B026  Star-arg unpacking after a keyword argument is strongly discouraged, because
# it only works when the keyword parameter is declared after all parameters supplied by
# the unpacked sequence, and this change of ordering can surprise and mislead readers.
# There was cpython discussion of disallowing this syntax, but legacy usage and parser
# limitations make it difficult: https://github.com/python/cpython/issues/82741

# Output:
# TypeError: my_function() got multiple values for argument 'regular_kwarg'

##########################################################################################
# Scenario 3.
##########################################################################################
print_args_types_values(**kwargs)

# Output:
# Type regular_kwarg:  <class 'int'>
# regular_kwarg:  1
# Type args:  <class 'tuple'>
# args:  (2, 3, 4, 5)
# Type kwargs:  <class 'dict'>
# kwargs:  {'kwarg1': 1, 'kwarg2': 2, 'kwarg3': 3}
