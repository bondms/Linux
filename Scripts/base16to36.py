#!/usr/bin/env python

import sys


def base36encode(number, alphabet="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"):
    """Converts an integer to a base36 string."""
    if not isinstance(number, int):
        raise TypeError("Number must be an integer")

    if number >= 0 and number <= 9:
        return alphabet[number]

    base36 = ""
    sign = ""

    if number < 0:
        sign = "-"
        number = -number

    while number != 0:
        number, i = divmod(number, len(alphabet))
        base36 = alphabet[i] + base36

    return sign + base36


def base16to36(base16str):
    return base36encode(int(base16str, 16))


if __name__ == "__main__":
    print(base16to36(sys.argv[1]))
