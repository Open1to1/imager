Open 1to1 Imager
================

To build type make. The first run will download the ubuntu root, install the neeed package, copy files, and build an ISO. On subsequent runs it will install new packages, and copy files from the files/ directory into the filesystem. Then, it will create the ISO.

Usefull make targets include
----------------------------

clean: Clean up the working directory. Remove everything that can be re-downloaded or re-generated

install-packages: Install the packages liste in the makefile

preparechroot: Get the chroot ready for package installation or other tasks

cleanchroot: Clean up the chroot, and prepare it for compression

swuashfs: Generate the squashfs filesystem for the ISO

isoimage: Create the ISO image.

Directories and Files
---------------------
fs/ Chroot environment that makes up the system booted by the live CD

files/ These files are copied into fs/ at build time

iso/ The files makeing up the live CD ISO

misc/ Scripts needed to build the imager
