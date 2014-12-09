generous project generator
==========================

The generous project generator is a tool that generates project files
for many IDEs with existing sources.

Why is it needed?
-----------------

Here's a list of things some IDEs cannot do:
  * One cross-platform project file.
  * Using a reference to a folder for source files

Furthermore, working in an heterogenous team which uses many platforms
and many IDEs makes it harder to use and maintain the project files
needed to compile the projects.

Some tools are doing project generation, but they are not specialized in
that venue; they generally take over the compilation process and leaves
the project to be nothing more than a shell that calls the build tool.

This project aims to use the native tools that the IDE would use to actually
compile the project.

Typical use cases
-----------------

  * Heterogenous team (Different platforms, different IDEs)
  * Mass generation of project files when releasing projects for easier 
    adoption.
  * Generating a project file for a project which has none.

When will it be ready?
----------------------

I wouldn't know.

Wishlist
-------

* IDE support (in order of priority/Usage in our team)
  * Visual studio 2010
  * NetBeans
  * CodeLite
  * Code::Blocks
  * Eclipse
* Project types
  * C++
  * C
* Support for custom project configuration (Debug, Release, Release With thingamabob, etc)

When a specific version of a software is mentioned, it means that support
for prior version is not a priority. If supporting it is trivial, it will
likely be done.

Any IDE or language not listed is not out-of-question. They are just not
a priority to get this out of the door.
