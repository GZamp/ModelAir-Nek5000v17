#!/bin/bash 

casename=duct
rm  -f $casename.sch
echo $casename > SESSION.NAME
echo $PWD/ >> SESSION.NAME

mpirun -n 4 ./nek5000 | tee log_01.txt

mkdir output_01
mv la2* s??duct0.f* t??duct0.f* pts* output_01

# clean:
# rm rs6duct0.f* duct0.f* s??duct0.f0000* t??duct0.f0000* lap* la2* pts* log*

