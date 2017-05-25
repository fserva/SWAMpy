CSIRO Internal Development Environment
======================================

This section provides a description of the internal development
environment being used during pre-release development on CSIRO systems.

*Tested on Bragg-l, but should also work in other environments*

> **note**
>
> Sambuca development is using virtual environments to facilitate
> testing and development. To enable use of the optimised numpy and
> scipy packages, the virtual environment is created with
> `--system-site-packages`. However, for testing the package
> installation and dependencies, a clean virtual environment should be
> used. The goal is to create a Sambuca package that will install
> cleanly using standard Python tools and have it "just work".

Once only
---------

1.  On Scientific Computing clusters, load the git module (otherwise
    make sure you have Git installed):

        $ module load git

2.  Setup virtualenvwrapper by adding the following 2 lines to your
    .bashrc (substituting your own desired locations):

        export WORKON_HOME=$HOME/.virtualenvs
        export PROJECT_HOME=~/projects

3.  If they don't already exist, create the .virtualenvs and projects
    directories specified in the previous step.
4.  Create a directory in projects to act as the top level sambuca
    directory:

        $ cd ~/projects/
        $ mkdir sambuca_project

5.  Clone the Git repositories for sambuca and sambuca\_core into the
    sambuca\_project directory:

        $ cd ~/projects/sambuca_project/
        $ git clone https://bitbucket.csiro.au/scm/~col52j/sambuca.git
        $ git clone https://bitbucket.csiro.au/scm/~col52j/sambuca_core.git

    You may also wish to get the Bioopti project, and the Bioopti
    Reference Data project:

        $ git clone https://bitbucket.csiro.au/scm/sam/bioopti.git
        $ git clone https://bitbucket.csiro.au/scm/sam/bioopti_data.git

6.  On Scientific Computing clusters, load the Python version used for
    development:

        $ module load python/3.4.3

    On other systems, you may need to manually install a Python 3
    scientific Python stack.

7.  Activate the virtualenvwrapper scripts:

        $ source /apps/python/3.4.3/bin/virtualenvwrapper_lazy.sh

8.  Change to the top-level sambuca project directory:

        $ cd ~/projects/sambuca_project/

9.  Make a virtual environment called sambuca that will be shared by
    sambuca and sambuca\_core, associate it with the project directory,
    and allow the virtual environment to access the system site packages
    (required for access to site-optimised packages like numpy and
    scipy).:

        $ mkvirtualenv -a . --system-site-packages sambuca

10. Ensure the virtual environment is activated:

        $ workon sambuca

11. Install the sambuca and sambuca\_core packages and dependencies into
    your virtual environment in development mode. This makes the
    packages available via symlinks to your development code, so that
    code changes are reflected in the package without reinstallation
    (although you need to restart your python environment, or use the
    IPython `%autoreload` extension).

    The makefile contains a workaround to the issue with sphinx and
    pytest that occurs when the `--system-site-packages` flag was used
    to create the virtual environment. The issue occurs if pytest or
    sphinx are available in the system packages, as they cannot load
    plugins that have been installed locally to the virtual environment.
    For this reason, the makefile forces these packages to be installed
    locally while still allowing access to the optimised numpy and scipy
    packages from the system:

        $ workon sambuca
        $ cdproject
        $ cd sambuca
        $ make sitepkg-develop
        $ cd ../sambuca_core
        $ make sitepkg-develop

Every time
----------

1.  Load the Python version used for development:

        $ module load python/3.4.3

2.  Activate the virtualenvwrapper scripts:

        $ source /apps/python/3.4.3/bin/virtualenvwrapper_lazy.sh

3.  Activate the sambuca virtual environment:

        $ workon sambuca

4.  You can now work on the sambuca python code. Any Python packages you
    install with pip will be installed into the virtual environment.
    System packages are still available.

Testing
-------

Tests are implemented with pytest, with integration into the setup.py
script. The simplest way to run the tests is to call py.test from the
project directory:

    $ py.test

The tox framework was tested, as it provides automated testing against
multiple Python versions (2 & 3). However, tox did not work correctly
with the system-site-packages setting. The system-site-packages setting
is required to access the system packages numpy and scipy. Compiling
these packages is difficult and makes the use of fully encapsulated
virtual enviroments problematic.

A workaround is to create separate virtual environments based on Python
2.7 and Python 3.4, and then run the tests within both environments. A
helper script makes this easier.

Using the MakeFile
------------------

A makefile is in the root folder. It is intended to simply common
development tasks. Using it is optional. The makefile supports at a
minimum the following targets:

1.  clean: removes the build and htmlcov (coverage reports) directories,
    as well as `__pycache__` and `*.pyc` files. Note that a clean also
    removes the generated documentation (as this is placed into
    `build/docs`).
2.  install-deps: installs development and test dependencies into your
    virtual environment (be sure to activate it first).
3.  develop: installs sambuca in development mode.
4.  lint: runs pylint.
5.  html: builds the HTML documentation.
6.  pdf: builds the documentation in PDF format.
7.  latex: builds LaTeX source, used to generate other formats.
8.  alldocs: builds all documentation formats.
9.  sdist: builds a source distribution.
10. bdist\_wheel: builds a universal wheel distribution.

