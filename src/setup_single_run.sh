#! /bin/bash

new_dir='../results/simulations/02-lens_single_'`date +%Y-%m-%d_%H:%M:%S`

echo 'copying 02-lens base directory: '`echo $new_dir`
cp -r 02-lens $new_dir

echo $new_dir

echo 'copying complete, taking you there now!'
cd $new_dir

