"""The module contains helper tools for validating and transforming Pydantic model data."""

from typing import Any, Callable, Optional

import orjson


def replace_empty_values_to_none(checked_value: Any) -> Any:
    """Replace empty lists, dictionaries and strings with None.

    Strings with values 'None' or '' are also replaced with None.
    """
    if isinstance(checked_value, (list, dict)) and not checked_value:
        return None
    elif isinstance(checked_value, str):
        if checked_value in {'None', ''} or not checked_value:
            return None
    else:
        return checked_value


def orjson_dumps(processed_value: Any, *, default: Optional[Callable[[Any], Any]]) -> Any:
    """Make `orjson` (de)serialisation.

    `orjson` takes care of `datetime` encoding natively.
    Documentation: https://pydantic-docs.helpmanual.io/usage/exporting_models/#custom-json-deserialisation
    """
    # orjson.dumps returns bytes, to match standard json.dumps we need to decode
    return orjson.dumps(processed_value, default=default).decode()


def convert_str_snake_to_camel(snake_str: str) -> str:
    """Convert string "snake_case" to "camelCase".

    :param snake_str: Snake case string, e.g. "birth_date" or "_birth_date".
    :return: Camel case string, e.g. "birthDate".
    """
    components = snake_str.lstrip('_').split('_')
    # We capitalize the first letter of each component except the first one
    # with the `title` method and join them together.
    return components[0] + ''.join(component.title() for component in components[1:])  # noqa: WPS221
