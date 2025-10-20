#!/usr/bin/env python

import argparse
import errno
import os
import random
import sys

DEFAULT_SEED = 0
DEFAULT_BLOCK_SIZE = 4096
DEFAULT_CHUNK_SIZE = DEFAULT_BLOCK_SIZE


# Wraps `random` to provide a consistent stream of bytes even if requests are
# not made consistently with regard to number of bytes requeted.
# Using `random` directly, reading two single bytes in sequence does not
# necessarily yield the same result as reading two bytes in one go.
class RandomBytes:
    def __init__(self, chunk_size=DEFAULT_CHUNK_SIZE):
        self.chunk_size = chunk_size
        self.buffer = b""

    # Replacment for `random.randbytes`.
    def randbytes(self, n):
        while len(self.buffer) < n:
            self.buffer += random.randbytes(self.chunk_size)

        result = self.buffer[:n]
        self.buffer = self.buffer[n:]
        return result

    # Replacement for `randbytes` which is less memory-inefficient when the
    # result is not required.
    def skipbytes(self, n):
        while n > self.chunk_size:
            _ = random.randbytes(self.chunk_size)
            n -= self.chunk_size
        _ = self.randbytes(n)


class OsFile:
    def __init__(self, path, flags):
        self.path = path
        self.flags = flags

    def __enter__(self):
        self.fd = os.open(path=self.path, flags=self.flags)
        return self.fd

    def __exit__(self, exc_type, exc_value, traceback):
        os.close(self.fd)


def auto_int(x):
    return int(x, 0)


def initialise(fd, seed, start, end, count, block_size):
    if count:
        if end:
            raise Exception("Both end and count specified")
        end = start + count

    if end is not None and end < start:
        raise Exception("End is before start")

    pos = start
    os.lseek(fd, pos, os.SEEK_SET)

    random.seed(seed)
    random_bytes = RandomBytes()
    random_bytes.skipbytes(pos)

    return (pos, end, random_bytes)


def read_fd(
    fd, seed=DEFAULT_SEED, start=0, end=None, count=None, block_size=DEFAULT_BLOCK_SIZE
):
    (pos, end, random_bytes) = initialise(
        fd=fd, seed=seed, start=start, end=end, count=count, block_size=block_size
    )

    while True:
        size_to_read = block_size if end is None else min(block_size, end - pos)
        print(f"Reading (0x{pos:012X}..0x{pos + size_to_read - 1:012X})...")
        actual = os.read(fd, size_to_read)
        if len(actual) != size_to_read:
            print(f"Partial read: {len(actual)} bytes")
        if not actual:
            print("End of read")
            return
        expected = random_bytes.randbytes(len(actual))
        if actual != expected:
            for index, pair in enumerate(zip(expected, actual)):
                if pair[0] != pair[1]:
                    raise Exception(f"Failed at position 0x{pos + index:012X}")
        pos += len(actual)


def read_path(
    file_path,
    seed=DEFAULT_SEED,
    start=0,
    end=None,
    count=None,
    block_size=DEFAULT_BLOCK_SIZE,
):
    with OsFile(path=file_path, flags=os.O_RDONLY) as fd:
        read_fd(
            fd=fd, seed=seed, start=start, end=end, count=count, block_size=block_size
        )


def write_fd(
    fd, seed=DEFAULT_SEED, start=0, end=None, count=None, block_size=DEFAULT_BLOCK_SIZE
):
    (pos, end, random_bytes) = initialise(
        fd=fd, seed=seed, start=start, end=end, count=count, block_size=block_size
    )

    while True:
        data = random_bytes.randbytes(
            block_size if end is None else min(block_size, end - pos)
        )
        print(f"Writing (0x{pos:012X}..0x{pos + len(data) - 1:012X})...")
        try:
            size_written = os.write(fd, data)
        except OSError as oserror:
            if oserror.errno != errno.ENOSPC:
                raise
            size_written = os.lseek(fd, 0, os.SEEK_CUR) - pos
        if size_written != len(data):
            print(f"Partial write: {size_written} bytes")
        if size_written == 0:
            print("End of data")
            return
        pos += size_written


def write_path(
    file_path,
    seed=DEFAULT_SEED,
    start=0,
    end=None,
    count=None,
    block_size=DEFAULT_BLOCK_SIZE,
):
    with OsFile(path=file_path, flags=os.O_WRONLY) as fd:
        write_fd(
            fd=fd, seed=seed, start=start, end=end, count=count, block_size=block_size
        )


def parse_args(argv):
    parser = argparse.ArgumentParser(prog="Storage Check")
    parser.add_argument("--file-path", required=True)
    parser.add_argument("--read", action="store_true")
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--seed", type=auto_int, default=0)
    parser.add_argument("--start", type=auto_int, default=0)
    parser.add_argument("--end", type=auto_int)
    parser.add_argument("--count", type=auto_int)
    parser.add_argument("--block-size", type=auto_int, default=DEFAULT_BLOCK_SIZE)
    return parser.parse_args(argv[1:])


def main(argv):
    args = parse_args(argv)

    print(f"File path: {args.file_path}")
    print(f"Seed: {args.seed} / 0x{args.seed:0012X}")
    print(f"Start: {args.start} / 0x{args.start:0012X}")
    print(f"End: {args.end}" + ("" if args.end is None else f" / 0x{args.end:0012X}"))
    print(
        f"Count: {args.count}"
        + ("" if args.count is None else f" / 0x{args.count:0012X}")
    )
    print(f"Block size: {args.block_size} / 0x{args.block_size:0012X}")

    if not (args.write or args.read):
        raise Exception("Nothing to do")

    if args.write:
        print("Writing...")
        write_path(
            file_path=args.file_path,
            seed=args.seed,
            start=args.start,
            end=args.end,
            count=args.count,
            block_size=args.block_size,
        )
    if args.read:
        print("Reading...")
        read_path(
            file_path=args.file_path,
            seed=args.seed,
            start=args.start,
            end=args.end,
            count=args.count,
            block_size=args.block_size,
        )
    print("Done.")


if __name__ == "__main__":
    main(sys.argv)
