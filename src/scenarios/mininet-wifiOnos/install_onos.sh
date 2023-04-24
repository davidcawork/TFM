#!/bin/bash

sudo apt update -y
sudo apt install -y git g++ unzip zip openjdk-11-jdk bzip2

wget -c  https://github.com/bazelbuild/bazel/releases/download/6.0.0-pre.20220421.3/bazel-6.0.0-pre.20220421.3-installer-linux-x86_64.sh
chmod +x bazel-6.0.0-pre.20220421.3-installer-linux-x86_64.sh
./bazel-6.0.0-pre.20220421.3-installer-linux-x86_64.sh --user 
export PATH=$PATH:$HOME/bin


git clone https://gerrit.onosproject.org/onos -b onos-2.5
echo "#ONOS" | tee -a ~/.bashrc
echo ". ~/onos/tools/dev/bash_profile" | tee -a ~/.bashrc
source .bashrc
cd onos && bazel build onos 

