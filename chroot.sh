#!/bin/bash

make preparechroot
chroot fs/ /environment.sh /bin/bash
