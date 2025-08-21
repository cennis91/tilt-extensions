#!/bin/bash

cd "$(dirname "$0")"

set -e

tilt ci
tilt down
