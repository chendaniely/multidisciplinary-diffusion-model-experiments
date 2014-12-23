#! /bin/bash
rm *.wt
rm *.ex
rm *.out
rm ./weights/*
# rm ./output/*
find . -type f -not -name './output/README.md' | xargs rm
rm ./lens_output/*
