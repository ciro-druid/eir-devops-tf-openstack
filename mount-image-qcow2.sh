#!/bin/bash




Step 1 - Enable NBD on the host

modprobe nbd max_part=8


Step 2 - Connect the QCOW2 as a network block device

qemu-nbd --connect=/dev/nbd0 /var/lib/vz/images/100/vm-100-disk-1.qcow2



Step 3 - List partitions inside the QCOW2

fdisk /dev/nbd0 -l



Step 4 - Mount the partition from the VM

mount /dev/nbd0p1 /mnt/somepoint/



You can also mount the filesystem with normal user permissions, ie. non-root:

mount /dev/nbd0p1 /mnt/somepoint -o uid=$UID,gid=$(id -g)



Step 5 - After you're done, unmount and disconnect

umount /mnt/somepoint/
qemu-nbd --disconnect /dev/nbd0
rmmod nbd
