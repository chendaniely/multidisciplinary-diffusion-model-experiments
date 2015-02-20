#! /bin/bash

echo 'copying 02-lens base directory'
cp 02-lens ../results/simulations/02-lens_single_`date +%Y-%m-%d_%H:%M:%S`

echo 'copying complete, taking you there now!'
cd ../results/simulations/02-lens_single_`date +%Y-%m-%d_%H:%M:%S`
