CBCBuildScripts
===============
By Matthew Thompson

Requirements
------------
* [Chumby Toolchain][]
* Local GCC toolchain
* Normal build tools

Running
-------

	make # sets /mnt/kiss/qt up for usage by the cbc build scripts
	
Description
-----------

This script downloads, builds, and installs Qt Embedded 4.5.2 and tslib 1.0 for the chumby, and installs them into /opt/chumbyqt/qt. It then creates a symlink from /mnt/kiss to /opt/chumbyqt, which allows the whole set up to be used by the cbc build scripts. On my box it takes 30-35 minutes to run (Pentium D, 2 gigs).

At the present, it unfortunately will ocassionally prompt you for your sudo password, mainly because I haven't yet figured out how to build qt without fully installing tslib. Qt will also ask you to agree to the LGPL. Both of these interactive prompts halt the build process, so at present this is not a set it and forget it type script.

[Chumby Toolchain]: http://wiki.chumby.com/mediawiki/index.php/GNU_Toolchain

