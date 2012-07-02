#!/bin/bash

chroot fs dpkg-query -W --showformat='${Package} ${Version}\n' > iso/casper/filesystem.manifest
cp -v iso/casper/filesystem.manifest iso/casper/filesystem.manifest-desktop
REMOVE='ubiquity ubiquity-frontend-gtk ubiquity-frontend-kde casper lupin-casper live-initramfs user-setup discover1 xresprobe os-prober libdebian-installer4'
for i in $REMOVE 
do
        sudo sed -i "/${i}/d" iso/casper/filesystem.manifest-desktop
done
