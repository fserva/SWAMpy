@echo off
setlocal EnableDelayedExpansion

REM Set CONDA_ENV to the name of the environment you wish to create.
REM TODO: this could be passed in as a command line arg
set CONDA_ENV=sambuca

echo ---- Creating Conda environment %CONDA_ENV%
conda create --yes --name %CONDA_ENV% --file conda_reqs_64.txt

echo ---- Activating Conda environment
call activate %CONDA_ENV%
conda info --envs

echo ---- Installing third-party pip packages
pip install --upgrade --requirement ./pip_reqs_64.txt

REM echo ---- Installing Sambuca Core in develop mode
cd ..\..\sambuca_core
python setup.py develop
pip install -e.[dev,test]

REM echo ---- Installing Sambuca in develop mode
cd ..\sambuca
python setup.py develop
pip install -e.[dev,test]

REM echo ---- Installing Bioopti in develop mode
cd ..\bioopti
python setup.py develop
pip install -e.[dev,test]

REM echo ---- Done!
