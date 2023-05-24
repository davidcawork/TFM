#!/usr/bin/python3

import os, sys, json, subprocess, json5

# MACROS


# Parse stats-flow
def parse_statsFlow(cmd):
    """
    Parse stats-flow command
    """
    a = cmd.replace("\n", "")
    b = a.split("stat_repl")[1]
    d = json5.loads(b)
    return None


# Get stats-flow
def get_statsFlow(params):
    """
    Execute dpctl stats-flow and capture stdout
    """
    return subprocess.run(
        ["dpctl", params, "stats-flow"], stdout=subprocess.PIPE
    ).stdout.decode("utf-8")


# Print stats-flow
def print_statsFlow():
    """
    print dpctl stats-flow parsed
    """
    print("-------------------")


# Main
if __name__ == "__main__":
    # Parse input data
    if len(sys.argv) <= 1:
        print("Please supply the datapath to use - example 'unix:/var/run/dp0'")
        sys.exit()

    # Vars
    cmd = get_statsFlow(sys.argv[1])

    # Parse cmd
    cmd_parsed = parse_statsFlow(cmd)

    # Print parsed cmd
    print_statsFlow(cmd_parsed)
