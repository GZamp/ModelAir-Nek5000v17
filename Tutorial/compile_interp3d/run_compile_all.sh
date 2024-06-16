#!/bin/bash

./compile_script --clean

cp duct.usr_a duct.usr

./compile_script --compile

mv nek5000 ../run_interp3d/nek5000a

cp duct.usr_b duct.usr

./compile_script --compile

mv nek5000 ../run_interp3d/nek5000b
