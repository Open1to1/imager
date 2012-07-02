all: bootstrap setupfs upgrade install-packages copy-files squashfs isoimage

clean: cleanfs
	rm -rf --one-file-system fs/
	rm -f iso/casper/filesystem.*
	rm -f iso/casper/vmlinuz
	rm -f iso/casper/initrd.img
	rm -f iso/isolinux/isolinux.bin
	rm -f iso/md5sum.txt
	rm -f boot.iso
	rm -f *-stamp

bootstrap: bootstrap-stamp
bootstrap-stamp:
	mkdir fs/
	@http_proxy=http://127.0.0.1:3142 debootstrap --arch=i386 precise fs/
	cp /etc/hosts /etc/resolv.conf fs/etc/
	cp /etc/apt/sources.list fs/etc/apt/
	cp misc/environment.sh fs/
	touch $@
	
setupfs: setupfs-stamp
setupfs-stamp:
	mount --bind /dev/ fs/dev/
	mount --bind /proc/ fs/proc/
	mount --bind /sys/ fs/sys/
	mount --bind /dev/pts/ fs/dev/pts/
	touch $@

setup-packages: setup-packages-stamp setupfs
setup-packages-stamp:
	chroot fs/ /environment.sh apt-get update
	chroot fs/ /environment.sh apt-get install --yes dbus
	touch $@

upgrade: setup-packages preparechroot
	chroot fs/ /environment.sh apt-get --yes upgrade

install-packages: setupfs
	chroot fs/ /environment.sh apt-get install --yes ubuntu-standard casper lupin-casper discover laptop-detect os-prober grub2 plymouth-x11 network-manager linux-generic xserver-xorg libqt4-gui fsarchiver metacity xinit xterm feh python-qt4 metacity-themes ubuntu-artwork pyqt4-dev-tools cifs-utils python-parted python-psutil

copy-files:
	cp -arv files/* fs/

preparechroot: preparechroot-stamp setupfs
preparechroot-stamp:
	cp misc/environment.sh fs/
	chroot fs/ /environment.sh rm -f /var/lib/dbus/machine-id
	chroot fs/ /environment.sh dbus-uuidgen --ensure
	chroot fs/ /environment.sh dpkg-divert --local --rename --add /sbin/initctl
	chroot fs/ /environment.sh ln -s /bin/true /sbin/initctl
	touch $@

cleanchroot:
	cp misc/removeoldkernels.sh fs/
	chroot fs/ /environment.sh /removeoldkernels.sh
	rm -f fs/removeoldkernels.sh
	chroot fs/ /environment.sh rm -f /var/lib/dbus/machine-id
	chroot fs/ /environment.sh rm -f /sbin/initctl
	-chroot fs/ /environment.sh dpkg-divert --rename --remove /sbin/initctl
	chroot fs/ /environment.sh rm -f /root/.bash_history
	chroot fs/ /environment.sh rm -rf /tmp/*
	chroot fs/ /environment.sh rm -f /etc/resolv.conf
	chroot fs/ /environment.sh apt-get clean
	rm -f fs/environment.sh
	rm -f preparechroot-stamp

squashfs: cleanchroot cleanfs
	rm -f iso/casper/filesystem.squashfs
	misc/makemanifest.sh
	sudo mksquashfs fs iso/casper/filesystem.squashfs

isoimage:
	mkdir -p iso/{casper,isolinux,install}
	cp fs/boot/vmlinuz-**.**.**-**-generic iso/casper/vmlinuz
	cp fs/boot/initrd.img-**.**.**-**-generic iso/casper/initrd.img
	cp /usr/lib/syslinux/isolinux.bin iso/isolinux/
	(cd iso && find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt && cd ../)
	(cd iso && sudo mkisofs -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../boot.iso . && cd ../)

cleanfs: 
	-mount | grep ${PWD}/fs/dev/pts 2>1 >/dev/null && umount -l fs/dev/pts/
	-mount | grep ${PWD}/fs/dev 2>1 >/dev/null && umount -l fs/dev/
	-mount | grep ${PWD}/fs/proc 2>1 >/dev/null && umount -l fs/proc/
	-mount | grep ${PWD}/fs/sys 2>1 >/dev/null && umount -l fs/sys/
	rm -f setupfs-stamp
