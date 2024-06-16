# UrbanFlowCases
Tutorial for Urban Flow simulations with Nek5000 and postprocessing using Matlab.

This tutorial is created to reproduce a reasonable workflow for the simulation for a small test case, which includes i) a simulation with 3 subsequent runs using restart, ii) sampling statistics, and iii) performe interpolation on a given mesh for further post-processing in an external code. The LES parameter and resolutions are not appropriate for an accurate simulation. 

Nek5000 is a CFD code using the spectral-element method (SEM). The latest version and documentation is available [here](https://nek5000.mcs.anl.gov/). In the spectral-element method, the computational domain is divived into "elements", and the solution is rapresented using a base of orthogonal polynomial within each element. This tutorial employes tripping to induce laminar-to-turbulent transition, which is implemented as proposed by (CITE), and the a relaxation-time filter for large-eddy simulations (LES), which is implemented as proposed by (CITE). The simulation code in this tutorial includes sampling full turbulence statistics, including the mean velocity and pressure fields, velocity and pressure derivatives, the Reynolds-stress tensor, and terms of the TKE budget (following the implementation by CITE). 

The Nek5000 version for which this tutorial is tested is stored on [Dropbox](https://www.dropbox.com/scl/fo/28syqj9pet6vmmckkscwh/h?dl=0&rlkey=a2xzygd3hsvdk4r22hldbdkzd).

The Matlab version for which this tutorial is tested is 20.21a.

## 1) Prerequisites
Prerequisites required with Ubuntu 20.04.

> sudo apt update
>
> sudo apt-get install build-essential libboost-system-dev libbost-thread-dev libopenmpi-dev openmpi-bin

Furthermore, **python3** and **matlab** for pre- and post-processing. 

## TO DO LIST (TIME SERIES)

1. remove vorticity and pressure.
2. enable write time series in single precision.
3. enable buffer size.

## 2) How to run

1. In **compile_tutorial**:
   - update paths in *compile_script* if needed.
   - compile:
     > ./compile_script --clean
     >
     > ./compile_script --compile
   - copy the executable: 
     > cp nek5000 ../run_tutorial 
2. In **run_tutorial**:
   - copy *duct.ma2* and *duct.re2* from [Dropbox](https://www.dropbox.com/scl/fo/jktzlrac3eygm5d55wtkj/h?dl=0&rlkey=bkndihcoa6ud0ag7pld7kvblw).
   - create the mesh for time series (*int_pos* file):
     > python3 writer_int_pos.py 
   - for the first run, make sure you are using *duct.par.init*:
     > cp duct.par.init duct.par
     >
     > source run_local.sh
   - for the second and third run, make sure you are using update *duct.par.res*: 
     > cp duct.par.res duct.par
   - update *run_local.sh* (change **output_01** in **output_02**) and run for the second time:
     > source run_local.sh
   - update *run_local.sh* (change **output_02** in **output_03**) and run for the third time:
     > source run_local.sh
   - ~~**_check_:**~~ at this point, you should have the following folders: **output_01**, **output_02**, and **output_03**, each containing 12 **la2** files, 3 for each of the 11 **s** files, 3 for each of the 4 **t** files, and the **pts** files for the time series.
   - ~~**_check_:**~~ check the time series files:
     > python3 reader_pts_fld.py
3. In **compile_post3d**:
   - update paths if needed and compile as in **compile_tutorial**
   - copy the executable: 
     > cp nek5000 ../run_post3d
4. In **run_post3d**:
   - copy mesh and stat files:
     > source copy_fields.sh
   - ~~**_check_:**~~ at this point, you should have a **STAT3D** folder, containing 6 for each of the **s** and **t** files.
   - run the post-processing script: 
     > source run_local.sh
   - ~~**_check_:**~~ at this point, you should have 22 **a** files and 8 **b** files.
5. In **compile_inter3d**:
   - update paths if needed and compile and copy the executables with:
   > source run_compile_all.sh
6. In **matlabScript**:
   - create the output folders in **run_interp3d**:
     > mkdir ../run_interp3d/ZSTAT
   - run the matlab script *int_mesh.m*.
   - repeat the same for **run_historyInt** (modify the path in *int_mesh.m*).
7. In **run_interp3d**:   
   - ~~**_check_:**~~ at this point, you should have a **ZSTAT** folder here, containing *x.fort*, *y.fort*, and *z.fort*.
   - copy the mesh files from **run_tutorial**.
   - run using:
     > source run_local.sh
   - ~~**_check_:**~~ at this point, you should have the folders **output_a** and **output_b**, containing, respectively 22 and 8 quartets of **L**, **U**, **V**, and **W** files and the *history2.txt* file.
8. In **compile_historyInt**:
   - update paths if needed and compile as in **compile_tutorial**
   - copy the executable: 
     > cp nek5000 ../run_historyInt/
9. In **run_historyInt**:
   - copy the snapshots with:
      > source copy_data.sh
   - copy the mesh files from **run_tutorial**.
   - update n. of *la2* files in *duct.par* (*userParam03*)
   - run using:
     > source run_local.sh
   -  ~~**_check_:**~~ at this point, you should have 33 **L**, **U**, **V**, and **W** files and the *history2.txt* file in **ZSTAT**.
10. In **matlabScript**:
   - Use *read_interpolated_data.m*. This script should plot the mean velocity and Reynolds stress components on a vertical plane just behind the obstacle.
   - Use *History_read_interpolated_data.m* to check history interpolated files.


## 3) Code description

The workflow described in this tutorial consists of four main steps:
1. Create a mesh.
2. Run the simulation with time series (work in progress).
3. Combine statistics and compute derivatives.
4. Interpolate and output statistics. 

### 1. Mesh 
Mesh files are created using [Parallel Work](https://go.parallel.works/), and stored on [Dropbox](https://www.dropbox.com/scl/fo/jktzlrac3eygm5d55wtkj/h?dl=0&rlkey=bkndihcoa6ud0ag7pld7kvblw). Mesh (**.re2**) and map (**.ma2**) binaries files are created together and need to be placed in the run folder. 

### 2. Simulation
Code for simulation (including tripping, LES filter, full statistics, no scalars).

**2. A: Compile the code (in *compile_tutorial*)** Compile the code in the compile folder, setting the proper variable values in **compile_script** for:
1. The source code path, via *SOURCE_ROOT*.
2. The compilers, via *FC* and *CC*.
3. Compiler options, if needed.

Furthermore, fortran variables in **SIZE** needs to be set to determine:
1. The number of elements in the mesh (*lelg*).
2. The polynomial order (*lx1* and *lxd*).
3. The number of MPI ranks of the simulation (*lpmin* and *lpmax*).
4. The number of considered scalar fields (*ldimt*).

To compile the code:

> ./compile_script --clean
> 
> ./compile_script --compile


After compilation, move the executable **nek5000** in *run_tutorial*.

**Note:** the number of elements in the mesh can be obtained from the header of either the **.re2** file.

**Note:** compilation is the same for the first run and subsequent runs, assuming that statistics are sampled in both cases.

**2. B: Provide mesh files** (in *run_tutorial*): Add the mesh binaries files to this folder. 

**2. C: Run the simulation** (in *run_tutorial*): Run the simulation in the run folder, after moving the executable **nek5000** in it. The simulation can run using the script **run_local.sh**, which also create the appropriate **SESSION.NAME** file. Modify this script to select the name of the **log** file and the number of MPI ranks.  Parameters such as Reynolds number, delta t, output frequency, LES scales and strength, tripping frequency and strengh, and solver tolerences are in the **.par** file. The **.par** also governs the restarting, via the *_CHKPOINT* section, and the statistic output, via the *_STAT* section. In the current version of the repository, the file **duct.par.init** is a suitable example for a simulation of 10,000 time steps, with a restart and statistic output after 5,000 steps and without reading restart (tripping and LES filter are not optimized for the Reynolds number and resolution of this tutorial). The file **duct.par.res** is the corresponding **.par** file for a case with the same parameters but reading restart files. Subtituite **duct.par** with **duct.par.init** or **duct.par.res** approriately.

**Note:** The number of MPI ranks employed in **run_local.sh**, and the mesh size need to be compatible with what set in the previous step. 

**Note:** Assuming that the number of time steps and the output frequencies for stat and restart files are consistent, the output of the simulation consits of:
1. Two sets of 3 restart files, organized in a list of 6 files, **rs6duct0.f00001**,..., **rs6duct0.f00006**. The first 3 restart files are restart files from the first half of the simulation, and the last 3 restart files are the from the second half of the simulation.
2. A first serie of 11 stat files, **s01duct0.f00001**, **s02duct0.f00001**, ..., **s11duct0.f00001**. Three series of this stat files will be created for each run  (**s##duct0.f00001**, ..., **s##duct0.f00003**). The first serie of these stat files is created for legacy reason and can be ignored, the second serie is created at the time of the first restart, and the third serie is created at the time of the second restart, when the simulation ends.
3. A second serie of 4 stat files, **t01duct0.f00001**, **t02duct0.f00001**, ..., **t04duct0.f00001**. Three series of this stat files will be created for each run  (**t0#duct0.f00001**, ..., **t0#duct0.f00003**).  The first serie of these stat files is created for legacy reason and can be ignored, the second serie is created at the time of the first restart, and the third serie is created at the time of the second restart, when the simulation ends.

**Note:** The following step requires to have the stat files from each run in folders named **output_01**, **output_02**, ...

**Note:** In addition to the stat and restart files, it is also possible to save full 3D instantaneous fields with the frequency set with **writeInterval** (standard output) or **userParam03** (includes additional scalar fields) in the **.par** file.

### 3. Post-processing statistics 
Code for combining statistics (full average) and computing derivatives. The input for this code are the **s##** and **t##** stat files from the previous step.

**3. A: Compile the code (in *compile_post3d*):** Compile using the **compile_script**, as for the simulation code. In this code, the stat files from multiple runs are averaged to create the full statistics, and should be provided already ordered and in a folder with name **STAT3D** in the run folder. Furthermore, a set of derivatives are computed with spectral accuracy, including derivatives of the mean fields. 

Given that lists of **s##duct0.f00001**, ..., **s##duct0.f000##** and **t0#duct0.f00001**, ..., **t0#duct0.f000##** are provided, the first and last stat files that are going to be averaged is set in the source code in **duct.usr**, using the variables *last_file* and *first_file* (TODO: this should be moved to a parameter). The version of the source code in the repository assumes that 3 subsequent simulations have been carried out, savings 2 set of stat files for each of them (the first simulation with a given initial condition, and the latter 2 using restarting), and that the first set of stat files is excluded from the complete statistics (this rapresents an initial transiet, which is discarded). In this case, the output of the entire set of simulations consists of 6 of each of the **s##** and **t##** stat files, and the only last 5 need to be averaged. Therefore, *first_file=2* and *last_file=6*.

After compilation, move the executable **nek5000** in *run_post3d*.

**3. B: Export the stat files (in *run_post3d*):** The script **copy_stat.sh** copies and sort the stat files from **output_##** folders in **run_tutorial/** to **run_post3d/STAT3D**, which is default location for to read statistic for the post-processing code.

**3. C: Run the post-processing code (in *run_post3d*):** Run the code using **run_local.sh**.

**Note:** The post-processing code in this step of the workflow (as well as that on the next step) uses Nek5000 in post-processing mode, *i.e.* without solving the governing equation. This is obtained setting to *0* the number of time steps in the **duct.par** file.

**Note:** The version of the code use in the tutorial assume that each stat file corresponds to simulation of the same number of time step (the average is not weighed with the average time of each stat file). 

**Note:** The output of this code is a list of 22 **a##** files (**a01duct0.f00001**, ..., **a22duct0.f00001**) files, and 8 **b##** files (**b01duct0.f00001**, ..., **b08duct0.f00001**).


### 4. Interpolation 
Code for interpolating statistic on a unstructured mesh. The input for this code are the **a##** and **b##** stat files from the previous step.

**4. A: Create the mesh for interpolation (in *matlabScripts/*):** The code for interpolation requires the list of point where the statistics will be interpolated. As an example, a verticale plane is created and exported in the proper format and path using the script **int_mesh.m**. 

**Note:** The format of the mesh is a general unstructured mesh, in the sense that the 3 spacial coordinates of all points are required. 

**4. B: Compile the code for interpolation (in *compile_interp3d/*):** The current version of this code has a termporary structure for historical reasons. Two different codes are used to interpolate separatly **a##** and **b##** files, and the source codes are **duct.usr_a** and **duct.usr_b**, respectively. At the compilation step in this tutorial, the script **run_compile_all.sh** is used to create two executables with names **nek5000a** and **nek5000b**, and move them in the run folder. This script uses twice the usual compilation script **compile_script**, which is the same as for the previous two steps. 

**Note:** The **SIZE** file contains the variables *lhis* and *IntSize*, which are the local and total numbers of point for interpolation, respectively. These variables are set consistently with the mesh size and number of MPI ranks. Note that the interpolation is a parallel operation, and consists of the following steps:
1. The interpolation points are equally distributed between MPI ranks (regardless of their location). 
2. Each interpolation point is assigned to the appropriate spectral element (this step corresponds to interpolation initialization in Nek5000).
3. For each field that needs to be interpolated, the base functions within the proper element are used to evaluate the field value at the interpolation point.

**4. C: Run the code for interpolation (in *run_interp3d/*):** Both the input (point for interpolation) and output (interpolated values) for the interpolation code are stored in the folder **ZSTAT/**. Assuming that the two executables **nek5000a** and **nek5000b** from the previous step are provided, use the script **run_local.sh** to performe the interpolation. The script perfomes the following: 
1. Copy the **a##** and **b##** stat files from **run_post3d/** to **run_interp3d/ZSTAT/**.
2. Create the **SESSION.NAME** file (this is in common with the standard run script).
3. Run **nek5000a** for the **a##** stat files and move the corresponding outpost to **output_a/**.
4. Run **nek5000b** for the **b##** stat files and move the corresponding outpost to **output_b/**. 

**Note:** The output of the interpolation code has a particular structure. It consists of binaries files that contain the list of interpolated values from each MPI rank. The bindaries files are one for each of the fields stored in the stat files, resulting in 22 **L##**, **U##**, **V##**, and **W##** files for **a##** stat files, and in 8 **L##**, **U##**, **V##**, and **W##** files for **b##** stat files. These lists of values are however not continous and a space separates the values interpolated by each MPI rank. The additional output file **history2.txt** contains the number of interpolated values from each MPI rank, which is needed to read the **L##**, **U##**, **V##**, and **W##**.

**4. D: Assemble statistics (in *matlabScripts/*):** The script **read_interpolated_data.m** is used to assemble the **L##**, **U##**, **V##**, and **W##** binaries files, using the information in **history2.txt**. The code also perform a simple test on the fields, showing the mininum of maximum value for each field, and creating contour plots for the three velocity components and six components of the Reynolds-stress tensor. 
 

## 4) Tutorial Description

The production cases for this kind of simulations use approximately $\approx 100\times10^3$ spectral elements and polynomial order $7^{\rm th}$, resulting in $\approx 100 \times 10^6$ grid points. The proper LES resolution is employed for the relaxation-time filter and the Reynolds number based on the velocity of the incoming flow, the obstacle height, and the kinematic viscosity is $10000$. This tutorial differs from the production cases in the following aspects:

1. The domain is shorter.
2. The Reynolds number is lower.
3. The resolution is enough to avoid numerical instabilities, but it does not fullfil the requirements of the LES filter. 

Tripping intensities and the LES parameters have been mantained as in the original setup at higher $Re$, so that there are in principle not appropriate for this test case. 

The current tutorial has in total $2,720$ spectral elements and can be run with polynomial order $5^{\rm th}$, with a total of approximately half a million grid points. 



