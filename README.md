Setup
=====

To install all required dependencies on an Archlinux system
just run `./install.py`. If you don't have an Archlinux system
you must make sure to install all required dependencies (have a look
at the `install.py` file) yourself.

Parts of the configuration (under `src`) is written in TypeScript and compiled
to Lua using [TypeScriptToLua](https://typescripttolua.github.io/). You can use
`yarn start` to watch for changes and compile to Lua while developing the config.
You can use `yarn build` to one-time compile the TypeScript to Lua code. This is also
called by the above mentioned `install.py` script.

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
* **src** - contains configurations written in TypeScript which will be compiled to Lua
* **theme** - contains the theming files configuring colors and more
* **types** - contains TypeScript definitions for awesome APIs and Lua code under `lib`
