#  Copyright (c) 2022. Viacheslav Kolupaev, https://vkolupaev.com/
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

"""Unit tests of the functions of the `pydantic_helpers.py` module."""

from typing import Any

import pytest

from src.boilerplate.pydantic_helpers import replace_empty_values_to_none


@pytest.mark.smoke
@pytest.mark.fast
class TestPydanticHelpers(object):
    """Unit tests of the functions of the `pydantic_helpers.py` module."""

    @pytest.mark.parametrize(
        'checked_value,expected', [
            # Case 1.
            (None, None),

            # Case 2.
            ([], None),

            # Case 3.
            ({}, None),

            # Case 4.
            ('None', None),

            # Case 5.
            ('', None),

            # Case 6.
            ('some value', 'some value'),
        ],
    )
    def test_replace_empty_values_to_none(
        self,
        checked_value: Any,
        expected: Any,
    ) -> None:
        """Test the correctness of the logic of the `replace_empty_values_to_none` function.

        GIVEN:
        * Case 1: the `checked_value` argument is None; expected = None;
        * OR Case 2: the `checked_value` argument is an empty list; expected = None;
        * OR Case 3: the `checked_value` argument is an empty dict; expected = None;
        * OR Case 4: the `checked_value` argument — 'None' string; expected = None;
        * OR Case 5: the `checked_value` argument is an empty string; expected = None;
        * OR Case 6: the `checked_value` argument — 'some value' string; expected = 'some value' string;

        WHEN: the `replace_empty_values_to_none` function is called with the specified argument;

        THEN: the function should return a value that matches what is expected.

        Args:
            checked_value: argument to be passed in the `replace_empty_values_to_none` function call.
            expected: the expected response from the `replace_empty_values_to_none` function.
        """
        assert replace_empty_values_to_none(checked_value=checked_value) == expected
