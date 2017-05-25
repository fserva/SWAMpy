=======
Sambuca
=======

* Free software: ??? license

Installation
------------
::

    pip install sambuca

Documentation
-------------
**To Do: insert link to documentation**

Development
-----------

There is a makefile in the project root with targets for the most common
development operations such as lint checks, running unit tests, building the
documentation, and building installing packages. See :ref:`makefile`.

`Bumpversion <https://pypi.python.org/pypi/bumpversion>`_ is used to manage the
package version numbers. This ensures that the version number is correctly
incremented in all required files. Please see the bumpversion documentation for
usage instructions, and do not edit the version strings directly.

To generate a Stash compatible README.md file from an rst file, use pandoc
prior to a Git commit. The ``./docs/csiro_development_environment.rst`` file is 
probably most appropriate during the pre-release phase of development::

    module load pandoc
    pandoc -o README.md ./docs/csiro_development_environment.rst

