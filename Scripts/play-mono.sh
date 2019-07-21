#!/bin/bash

set -eux
set -o pipefail

play "$@" channels 1
