#!/bin/sh -l

# Ensure the workflow fails on error
set -e

crond -l 2 -f
