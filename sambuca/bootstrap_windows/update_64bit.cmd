@echo off
setlocal EnableDelayedExpansion

REM Set CONDA_ENV to the name of the environment you wish to create.
REM TODO: this could be passed in as a command line arg
set CONDA_ENV=inundation

echo ---- Activating Conda environment
call activate %CONDA_ENV%

echo ---- Updating Conda environment
conda install --file ./conda_reqs_64.txt

echo ---- Updating pip packages
pip install --requirement ./pip_reqs_64.txt

echo ---- Done!
