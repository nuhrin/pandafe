Pandafe
=======

Pandafe is a sort of "universal" SDL frontend for [Pandora](http://openpandora.org/) games and emulators. 

It was written especially for the Pandora, with the following goals:

* browse and run all roms and games from a single program
* specify commandline options for each game via a menu
* be fully configurable and extendable via the program itself
* use only dpad and buttons to do all this (no touching, heh)
* persist data via yaml, for human reading/writing/sharing

For more information see README.

Download
--------
Latest pnd is available at:  
http://repo.openpandora.org/?page=detail&app=package.pandafe

Compiling from tarball
----------------------
You will need to either compile natively on your pandora or use an appropriate cross-compiler.   
See: http://boards.openpandora.org/index.php?/topic/7173-sdk-developer-tools-documentation-updated/

Examples:

freamon's [native development tools](http://repo.openpandora.org/?page=detail&app=cdevtools.freamon.40n8e)  
```shell
$ addipk pandora-libpnd-dev
$ addipk vte-dev
$ ./configure
$ make pnd
```

sebt3's [toolchain](http://sebt3.openpandora.org/buildtools/)  
```shell
$ setprj
$ pndconfigure  
$ make pnd  
```

Compiling from git
------------------
You will need [Vala](https://live.gnome.org/Vala) 0.18.0 to compile from the git source.

Once that build requirement is fulfilled you can simply:  
```shell
$ ./autogen.sh
$ make pnd
```

If installing Vala on the compilation host system is not feasible you can:  

* install Vala 0.18 on another system
* create a tarball there (which will include generated C code)  

```shell
$ ./autogen.sh
$ make && make dist
```

* follow the _Compiling from tarball_ steps above

Acknowledgements
----------------
Interaction design & testing by Stefan Nowak (porg).
