#!/usr/bin/env python

import argparse
import errno
import os
import random
import sys

DEFAULT_SEED = 0
DEFAULT_BLOCK_SIZE = 4096
DEFAULT_CHUNK_SIZE = DEFAULT_BLOCK_SIZE


# `RandomBytes` wraps `random.randbytes` to read the date in consistently-sized
# chunks.
# This is necessary to ensure reproducibility.
# Reading two single bytes in sequence does not yield the same result as reading
# two bytes in one go.
class RandomBytes:
    def __init__(self, chunk_size=DEFAULT_CHUNK_SIZE):
        self.chunk_size = chunk_size
        self.buffer = b""

    def randbytes(self, n):
        if len(self.buffer) < n:
            self.buffer += random.randbytes(self.chunk_size)

        result = self.buffer[:n]
        self.buffer = self.buffer[n:]
        return result


class OsFile:
    def __init__(self, path, flags):
        self.path = path
        self.flags = flags

    def __enter__(self):
        self.fd = os.open(path=self.path, flags=self.flags)
        return self.fd

    def __exit__(self, exc_type, exc_value, traceback):
        os.close(self.fd)


def read_fd(
    fd, seed=DEFAULT_SEED, start=0, end=None, count=None, block_size=DEFAULT_BLOCK_SIZE
):
    if count:
        if end:
            raise Exception("Both end and count specified")
        end = start + count

    if end < start:
        raise Exception("End is before start")

    pos = start
    os.lseek(fd, pos, os.SEEK_SET)

    random.seed(seed)
    random_bytes = RandomBytes()
    _ = random_bytes.randbytes(pos)

    while True:
        size_to_read = block_size if end is None else min(block_size, end - pos)
        print(f"Reading (0x{pos:012X}..0x{pos + size_to_read:012X})...")
        actual = os.read(fd, size_to_read)
        if len(actual) != size_to_read:
            print(f"Partial read: {len(actual)} bytes")
        if not actual:
            print("End of read")
            return
        expected = random_bytes.randbytes(len(actual))
        if actual != expected:
            raise Exception("Failed")
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
    if count:
        if end:
            raise Exception("Both end and count specified")
        end = start + count

    if end < start:
        raise Exception("End is before start")

    pos = start
    os.lseek(fd, pos, os.SEEK_SET)

    random.seed(seed)
    random_bytes = RandomBytes()
    _ = random_bytes.randbytes(pos)

    while True:
        data = random_bytes.randbytes(
            block_size if end is None else min(block_size, end - pos)
        )
        print(f"Writing (0x{pos:012X}..0x{pos + len(data):012X})...")
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
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument("--start", type=int, default=0)
    parser.add_argument("--end", type=int)
    parser.add_argument("--count", type=int)
    parser.add_argument("--block-size", type=int, default=DEFAULT_BLOCK_SIZE)
    return parser.parse_args(argv[1:])


def main(argv):
    args = parse_args(argv)

    print(f"File path: {args.file_path}")
    print(f"Seed: {args.seed}")
    print(f"Start: {args.start}")
    print(f"End: {args.end}")
    print(f"Count: {args.count}")
    print(f"Block size: {args.block_size}")

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
