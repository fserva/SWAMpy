============
Contributing
============

Contributions are welcome, and they are greatly appreciated! Every
little bit helps, and credit will always be given.

Bug reports
-----------

When `reporting a bug <https://jira.csiro.au/sambuca>`_ please include:

    * Your operating system name and version.
    * Any details about your local setup that might be helpful in troubleshooting.
    * The Sambuca package version.
    * Detailed steps to reproduce the bug.

Documentation improvements
--------------------------

Sambuca could always use more documentation, whether as part of the
official Sambuca docs, in docstrings, or even on the web in blog posts,
articles, and such.

.. note:: This project uses Google-style docstrings.
   Contributed code should follow the same conventions.
   For examples, please see the `Napoleon examples
   <http://sphinxcontrib-napoleon.readthedocs.org/en/latest/example_google.html>`_,
   or the `Google Python Style Guide 
   <http://google-styleguide.googlecode.com/svn/trunk/pyguide.html>`_.
   

Feature requests and feedback
-----------------------------

The best way to send feedback is to `file an issue. <https://jira.csiro.au/sambuca>`_

If you are proposing a feature:

* Explain in detail how it would work.
* Keep the scope as narrow as possible, to make it easier to implement.
* Remember that this is a volunteer-driven project, and that contributions are welcome :)

Or, implement the feature yourself and submit a pull request.

Development
-----------

To set up `sambuca` for local development:


*To Do*: Once Sambuca is on GitHub (or somewhere similar), the following
instructions may make a useful template.

1. `Fork Sambuca on GitHub <https://github.com/...>`_.
2. Clone your fork locally::

    git clone git@github.com:your_name_here/sambuca.git

3. Create a branch for local development::

    git checkout -b name-of-your-bugfix-or-feature

   Now you can make your changes locally.

4. When you're done making changes, run all the tests, doc builder and pylint
   checks::

    py.test
    pylint ./src/sambuca/
    sphinx-build -b html docs build/docs

   Or, using the project makefile::

    make clean lint tests docs

5. Commit your changes and push your branch to GitHub::

    git add .
    git commit -m "Your detailed description of your changes."
    git push origin name-of-your-bugfix-or-feature

6. Submit a pull request through the GitHub website.

Pull Request Guidelines
-----------------------

If you need some code review or feedback while you're developing the code just make the pull request.

For merging, you should:

1. Include passing tests (run ``py.test``)
2. Update documentation when there's new API, functionality etc.
3. Add a note to ``CHANGELOG.rst`` about the changes.
4. Add yourself to ``AUTHORS.rst``.
