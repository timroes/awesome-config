Setup
=====

To install all required dependencies on an Archlinux system
just run `./install.sh`. If you don't have an Archlinux system
you must make sure to install all required dependencies (have a look
at the `install.sh` file) yourself.

Structure
=========

* **conf.d** - Contains the actual configuration read by
  `rc.lua` to setup my awesome
* **configs** - Contains several configuration files for
  external programs and a config(.sample).yml to
  configure my config slightly different on different machines
* **lib** - Contains alls modules, mainly *lunaconf* a custom
  module which includes all my widgets and utility functions which
  are used inside `conf.d`
* **scripts** - Contains some non-lua scripts, which will be called
  from within the configuration or library
* **theme** - contains the theming files configuring colors and more
