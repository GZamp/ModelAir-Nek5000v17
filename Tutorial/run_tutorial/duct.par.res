#
# nek parameter file
#
[GENERAL] 
#startFrom = duct0.f00005
stopAt = numSteps #endTime
#endTime = 30.0
numSteps = 103

dt = -5.0e-04
timeStepper = bdf3 #char #steady
variableDt = no
targetCFL = 0.3

writeControl = timeStep #runTime
writeInterval = 100000

dealiasing = yes
filtering = hpfrt
filterWeight = 20
filterCutoffRatio = 0.75

#userParam01 = 1		 # param(54) fixed flow rate dir.
#userParam02 = 9.1575     # param(55) vol. flow rate
userParam03 = 10   	 # L2FREQ
userParam04 = 0	   	 # IFCHKPTRST
userParam05 = 0     	 # FIXGEOM

[PROBLEMTYPE]
stressFormulation = no
#dp0dt = yes
variableProperties = no

[PRESSURE]
#preconditioner = # Schwarz is default for Nekp4est - this line should be commented0
residualTol = 1e-6
residualProj = no

[VELOCITY]
residualTol = 1e-6
residualProj = no
density = 1.0
viscosity = -1000
advection = yes

#
[_RUNPAR]               # Runtime parameter section for rprm module
PARFWRITE            = no                     # Do we write runtime parameter file
PARFNAME             = outparfile             # Runtime parameter file name for output (without .par)
#
[_MONITOR]              # Runtime parameter section for monitor module
LOGLEVEL             = 4                      # Logging threshold for toolboxes
WALLTIME             = 1.0E+09                 # Simulation wall time
#
[_STAT]             # Runtime paramere section for statistics module
AVSTEP               = 10
IOSTEP               = 50
#
[_TSRS]             # Runtime paramere section for statistics module
SMPSTEP              = 20                  # Frequency of sampling
#
[_CHKPOINT]             # Runtime paramere section for checkpoint module
READCHKPT            = yes                   # Restart from checkpoint
CHKPFNUMBER          = 2                      # Restart file number
CHKPINTERVAL         = 50                 # Checkpoint saving frequency (number of time steps)
#
[_TRIPPING]             # Runtime paramere section for tripping module
NLINE                = 1                      # Number of tripping lines
TIAMP                = 0.00000000E+00         # Time independent amplitude
TDAMP                = 5.00000000E+00         # Time dependent amplitude
SPOSX01              = -9.0000000E+00         # Starting pont X
SPOSY01              = 0.00000000E+00         # Starting pont Y
SPOSZ01              = -2.000000E+00         # Starting pont Z
EPOSX01              = -9.0000000E+00         # Ending pont X
EPOSY01              = 0.00000000E+00         # Ending pont Y
EPOSZ01              = 2.000000E+00         # Ending pont Z
SMTHX01              = 0.18000000E+00         # Smoothing length X
SMTHY01              = 0.04500000E+00         # Smoothing length Y
SMTHZ01              = 0.00000000E+00         # Smoothing length Z
ROTA01               = 0.00000000E+00         # Rotation angle in radians
NMODE01		     = 52		      # Number of Fourier modes
TDT01		     = 0.018000000E+00	      # Time step for tripping
SPOSX02              = 100.000000E+00         # Starting pont X
SPOSY02              = 0.99430000E+00         # Starting pont Y
SPOSZ02              = 0.00000000E+00         # Starting pont Z
EPOSX02              = 100.000000E+00         # Ending pont X
EPOSY02              = 0.99430000E+00         # Ending pont Y
EPOSZ02              = 4.50000000E+00         # Ending pont Z
SMTHX02              = 0.28000000E+00         # Smoothing length X
SMTHY02              = 0.07000000E+00         # Smoothing length Y
SMTHZ02              = 0.00000000E+00         # Smoothing length Z
ROTA02               = 0.12300000E+00         # Rotation angle in radians
NMODE02		     = 76		      # Number of Fourier modes
TDT02		     = 0.08000000E+00	      # Time step for tripping
