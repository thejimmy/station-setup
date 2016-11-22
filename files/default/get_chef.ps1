pushd (gi Env:\HOMEPATH).Value
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex;
./install.ps1
popd
