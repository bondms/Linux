#!/usr/bin/env python

import argparse
import random
import signal
import subprocess


def parse_arguments():
    parser = argparse.ArgumentParser()

    parser.add_argument("--level-volume", action="store_true")
    parser.add_argument("--mono", action="store_true")
    parser.add_argument("--shuffle", action="store_true")

    parser.add_argument("tracks", nargs="+")

    return parser.parse_args()


class SoxCommandLineGenerator:
    def __init__(self):
        self.gain = 0
        self.mono = False
        self.track = ""

    def set_gain(self, gain):
        self.gain = gain

    def set_mono(self):
        self.mono = True

    def set_track(self, track):
        self.track = track

    def command_line(self):
        if not self.track:
            raise Exception("No track specified")

        command_line = ["play"]

        command_line.append(self.track)

        command_line.extend(["-replay-gain", "off", "gain", str(self.gain)])

        if self.mono:
            command_line.extend(["channels", "1"])

        return command_line


def execute_interactively(items):
    for item in items:
        try:
            item
        except Exception:
            while True:
                user_response = input("Continue (y/n)? ")
                if user_response == "y" or user_response == "Y":
                    break
                if user_response == "n" or user_response == "N":
                    raise


class Player:
    def __init__(self):
        self.level_volume = False
        self.mono = False
        self.shuffle = False

        self.tracks = []

    def set_level_volume(self):
        self.level_volume = True

    def set_mono(self):
        self.mono = True

    def set_shuffle(self):
        self.shuffle = True

    def set_tracks(self, tracks):
        self.tracks = tracks

    def play(self):
        command_line = []
        if not self.tracks:
            raise Exception("No tracks to play")

        if self.shuffle:
            random.shuffle(self.tracks)

        if self.level_volume:
            # gain = $(track-replay-gain.sh "$1")
            # command_line += ["-replay-gain", "off", "gain", gain]
            raise Exception("Level volume: Not yet implemented")

        if self.mono:
            command_line += ["channels", "1"]

        original_handler = signal.signal(signal.SIGINT, signal.SIG_IGN)
        try:
            subprocess.check_call(command_line)
        finally:
            signal.signal(signal.SIGINT, original_handler)


if __name__ == "__main__":
    items = [lambda: print("1"), lambda: print("2")]
    execute_interactively(items)

    raise Exception("Not yet implemented")

    arguments = parse_arguments()

    player = Player()

    if arguments.mono:
        player.set_mono()

    if arguments.shuffle:
        player.set_shuffle()

    if arguments.level_volume:
        player.set_level_volume()

    player.set_tracks(arguments.tracks)

    player.play()
