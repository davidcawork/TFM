#!/usr/bin/python3

import os
import sys
import json
import subprocess
import re

# MACROS


# Parse stats-flow
def parse_statsFlow(cmd):
    """
    Parse stats-flow command
    """
    cmd_fmt = ((cmd.replace("\n", "")).split("stat_repl")[1])
    cmd_json_fmt = re.sub("\[(\w+){", r'["\1",{',
                          re.sub("(\w+)=", r'"\1":',  cmd_fmt))
    cmd_json_fmt = re.sub(r'oxm\{.*?\}', lambda match: match.group(
        0).replace('"', "'"), cmd_json_fmt)
    return json.loads(cmd_json_fmt)


# Get stats-flow
def get_statsFlow(params):
    """
    Execute dpctl stats-flow and capture stdout
    """
    return subprocess.run(
        ["dpctl", params, "stats-flow"], stdout=subprocess.PIPE
    ).stdout.decode("utf-8")


# Print stats-flow
def print_statsFlow(data):
    """
    print dpctl stats-flow parsed
    """
    stats = data["stats"]

    for stat in stats:
        print("---------------------------------- Table " +
              stat['table']+" --------------------------------")
        print("[+] Match: " + stat['match'])
        print("[+] Duration: " + stat['dur_s'])
        print("[+] Prio: " + stat['prio'])
        print("[+] Pkt cnt: " + stat['pkt_cnt'])
        print("[+] Byte cnt: " + stat['byte_cnt'])
        print("[+] Insts: " + str(stat['insts']))
        print("---------------------------------------------------------------------------")


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
