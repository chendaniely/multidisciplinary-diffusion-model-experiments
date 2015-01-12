#! /bin/bash
rm *.wt
rm *.ex
rm *.out
rm ./weights/*
rm ./output/*
rm ./lens_output/*

mkdir ./output
echo "Output folder for model runs.  Nothing in here should be tracked.
This README is mostly here so the 'output' folder exists when git cloned
" > ./output/README.md
