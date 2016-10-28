#!/bin/bash
hostMAC=fa:16:3e:97:2c:6f
hostUname=#uname -r
hostname=kaka
hostIP=10.0.101.116
GateWay=10.0.101.116
dns=10.0.101.116
#apt-get install dhcp3-server tftpd-hpa syslinux nfs-kernel-server initramfs-tools

#allow booting;
#slightly different configuration for an internal subnet
echo "subnet 10.0.101.0 netmask 255.255.255.0 {" > /etc/dhcp/dhcpd.conf
echo "range 10.0.101.150 10.0.101.234;" >> /etc/dhcp/dhcpd.conf
echo "option domain-name-servers ${dns};" >> /etc/dhcp/dhcpd.conf
echo "filename \"pxelinux.0\";" >> /etc/dhcp/dhcpd.conf
echo "}" >> /etc/dhcp/dhcpd.conf

#/etc/default/tftpd-hpa
sed -i "/^TFTP_OPTIONS/cTFTP_OPTIONS=\"-l -s /var/lib/tftpboot\"" /etc/default/tftpd-hpa
echo "RUN_DAEMON=\"yes\"" >> /etc/default/tftpd-hpa

#Create Pxelinux.cfg 
mkdir /var/lib/tftpboot/pxelinux.cfg/
cp /usr/lib/syslinux/pxelinux.0 /var/lib/tftpboot

#config default
#NOTE1: your nfs server IP address, kernel name, and initrd name will likely be different. If you have a preconfi#gured system the names should be the names of the kernel and initrd (see below) on the client system
#NOTE2: to find the vmlinuz type uname -r
#NOTE3: There are more options available such as MAC or IP identification for multiple config files see syslinux/pxelinux documentation for help.
#NOTE4: Newer distributions might require that you append ",rw" to the end of the "nfsroot=" specification, to prevent a race in the Upstart version of the statd and portmap scripts.

echo "LABEL linux" > /var/lib/tftpboot/pxelinux.cfg/default 
echo "KERNEL vmlinuz-${hostUname}" >> /var/lib/tftpboot/pxelinux.cfg/default 
echo "APPEND root=/var/lib/nfs initrd=initrd.img-${hostUname} nfsroot=${hostIP}:/usr/local/nfsroot ip=dhcp rw" >>  /var/lib/tftpboot/pxelinux.cfg/default

chmod -R 777 /var/lib/tftpboot

#restart all-services
service tftpd-hpa restart
service isc-dhcp-server restart

mkdir /usr/local/nfsroot
#echo "/usr/local/nfsroot             127.0.0.1(rw,no_root_squash,async,insecure,no_subtree_check)" >> /etc/exports
echo "/usr/local/nfsroot ${hostIP}(rw,no_root_squash,async,insecure,no_subtree_check)" >> /etc/exports
chmod -R 777 /usr/local/nfsroot
chmod -R 777 /usr/local
chmod -R 777 /usr
exportfs -rv

sed -i "/^BOOT=/cBOOT=nfs" /etc/initramfs-tools/initramfs.conf
sed -i "/^MODULES=/cMODULES=netboot" /etc/initramfs-tools/initramfs.conf

mkinitramfs -o ~/initrd.img-`uname -r`

#NOTE: If the client source installation you copied the files from should remain bootable and usable from local hard disk, restore the former BOOT=local and MODULES=most options you changed in /etc/initramfs-tools/initramfs.conf. Otherwise, the first time you update the kernel image on the originating installation, the initram will be built for network boot, giving you "can't open /tmp/net-eth0.conf" and "kernel panic". Skip this step if you no longer need the source client installation.

mount -t nfs -o nolock ${hostIP}:/usr/local/nfsroot /mnt
#cp -ax /. /mnt/.
#cp -ax /dev/. /mnt/dev/.
cp /home/ubuntu/ubuntu-14.04.2-server-amd64.iso /mnt/

cp ~/vmlinuz-`uname -r` /var/lib/tftpboot/
cp ~/initrd.img-`uname -r` /var/lib/tftpboot/

echo "# /etc/fstab: static file system information." > /usr/local/nfsroot/fstab
echo "#" >> /usr/local/nfsroot/fstab
echo "# <file system> <mount point>   <type>  <options>       <dump>  <pass>" >> /usr/local/nfsroot/fstab
echo "proc            /proc           proc    defaults        0       0" >> /usr/local/nfsroot/fstab
echo "/dev/nfs       /               nfs    defaults          1       1" >> /usr/local/nfsroot/fstab
echo "none            /tmp            tmpfs   defaults        0       0" >> /usr/local/nfsroot/fstab
echo "none            /var/run        tmpfs   defaults        0       0" >> /usr/local/nfsroot/fstab
echo "none            /var/lock       tmpfs   defaults        0       0" >> /usr/local/nfsroot/fstab
echo "none            /var/tmp        tmpfs   defaults        0       0" >> /usr/local/nfsroot/fstab
echo "/dev/hdc        /media/cdrom0   udf,iso9660 user,noauto 0       0" >> /usr/local/nfsroot/fstab
