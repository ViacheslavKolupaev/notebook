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

"""Convert milliseconds to seconds, minutes and hours and print the resulting values."""


def convert_milliseconds(millis: int) -> tuple[float, float, float]:
    """Convert milliseconds to seconds, minutes, hours."""
    seconds: float = millis / 1000
    minutes: float = millis / (1000 * 60)
    hours: float = millis / (1000 * 60 * 60)
    return seconds, minutes, hours


def print_values_with_proper_formatting(
    milliseconds: int,
    seconds: float,
    minutes: float,
    hours: float,
) -> None:
    """Print received values with proper formatting."""
    # Python documentation > Format Specification Mini-Language:
    # https://docs.python.org/3/library/string.html#format-specification-mini-language
    print(
        (
            '{milliseconds:>_d} ms. | ' +
            '{seconds:>_.2f} s. | ' +
            '{minutes:>_.1f} min. | ' +
            '{hours:>_.1f} h.'
        ).format(
            milliseconds=milliseconds,
            seconds=seconds,
            minutes=minutes,
            hours=hours,
        ),
    )


def main() -> None:
    """Execute the main function of the module."""
    milliseconds: int = int(input('Enter duration in milliseconds: '))
    if milliseconds < 0:
        raise ValueError('The value must be non-negative.')

    seconds, minutes, hours = convert_milliseconds(milliseconds)
    print_values_with_proper_formatting(milliseconds, seconds, minutes, hours)


if __name__ == '__main__':
    main()
