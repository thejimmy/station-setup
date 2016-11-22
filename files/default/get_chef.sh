#!/bin/sh
sudo yum install curl -y
pushd ~
curl -L https://omnitruck.chef.io/install.sh | sudo bash
# rm install.sh
popd
