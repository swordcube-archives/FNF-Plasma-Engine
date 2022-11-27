#! /bin/sh
lime build linux -debug
cd export/debug/linux/bin/
./PlasmaEngine -updatebuild -livereload
cd ../../../../