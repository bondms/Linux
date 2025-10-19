import argparse
import os
import random
import sys

class OsFile:
    def __init__(self, path, flags):
        self.path = path
        self.flags = flags

    def __enter__(self):
        self.fd = os.open(path=self.path, flags=self.flags)
        return self.fd

    def __exit__(self, exc_type, exc_value, traceback):
        os.close(self.fd)

def read_fd(fd, seed, limit):
    random.seed(seed)
    pos = 0
    while True:
        actual = os.read(fd, min(4096, limit-pos))
        if not actual:
            print("End of read")
            return
        pos += len(actual)
        print("Checking...")
        expected = random.randbytes(len(actual))
        if actual != expected:
            raise Exception("Failed")

def read_path(file_path, seed, limit):
    with OsFile(path=file_path, flags=os.O_RDONLY) as fd:
        read_fd(fd=fd, seed=seed, limit=limit)

def write_fd(fd, seed, limit):
    random.seed(seed)
    pos = 0
    while True:
        data = random.randbytes(min(4096, limit-pos))
        pos += len(data)
        if 0 == os.write(fd, data):
            print("End of data")
            return
        print("Writing...")

def write_path(file_path, seed, limit):
    with OsFile(path=file_path, flags=os.O_WRONLY) as fd:
        write_fd(fd=fd, seed=seed, limit=limit)

def parse_args(argv):
    parser = argparse.ArgumentParser(prog='Storage Check')
    parser.add_argument('--filepath', required=True)
    parser.add_argument('--read', action='store_true')
    parser.add_argument('--write', action='store_true')
    parser.add_argument('--seed', type=int, default=0)
    parser.add_argument('--limit', type=int)
    return parser.parse_args(argv[1:])

def main(argv):
    args = parse_args(argv)

    print(f"Seed: {args.seed}")
    print(f"Limit: {args.limit}")

    if args.write:
        write_path(file_path=args.filepath, seed=args.seed, limit=args.limit)
    if args.read:
        read_path(file_path=args.filepath, seed=args.seed, limit=args.limit)

if __name__ == '__main__':
    main(sys.argv)
