reboot
eula --agreed
text
firstboot --disable
ignoredisk --only-use=vda
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
network  --bootproto=dhcp --device=eth0 --onboot=off --ipv6=auto --hostname=localhost.localdomain
repo --name=os      --baseurl=http://mirror.centos.org/altarch/7/os/aarch64/
repo --name=extras  --baseurl=http://mirror.centos.org/altarch/7/extras/aarch64/
repo --name=updates --baseurl=http://mirror.centos.org/altarch/7/updates/aarch64/
rootpw --lock --iscrypted thereisnopasswordanditslocked

## Debug user. uncomment as needed for local account
#user --name centos --plaintext --password centos --homedir /home/centos --groups wheel
timezone --isUtc UTC
bootloader  --boot-drive=vda
autopart --type=plain
clearpart --all --initlabel --drives=vda

%packages
@core
cloud-init
chrony
nfs-utils
rsync
tar
yum-utils
dracut-config-generic
dracut-norescue
-aic94xx-firmware
-alsa-firmware
-alsa-lib
-alsa-tools-firmware
-iprutils
-ivtv-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl105-firmware
-iwl135-firmware
-iwl2000-firmware
-iwl2030-firmware
-iwl3160-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6000g2b-firmware
-iwl6050-firmware
-iwl7260-firmware

%end

%post

# Needed for install, not so much for cloud.
yum -C -y remove firewalld --setopt="clean_requirements_on_remove=1"
yum -C -y remove avahi\* Network\*

cat > /etc/sysconfig/network << EOF
NETWORKING=yes
NOZEROCONF=yes
EOF

# Ensure we're not backing in a mac addr.
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="yes"
PEERDNS="yes"
IPV6INIT="no"
PERSISTENT_DHCLIENT="1"
EOF

# Let mirrors know it's cloud
echo 'genclo' > /etc/yum/vars/infra

# Fix selinux context
echo "Fixing SELinux contexts."
touch /var/log/cron
touch /var/log/boot.log
mkdir -p /var/cache/yum
/usr/sbin/fixfiles -R -a restore

# make sure firstboot doesn't start
echo "RUN_FIRSTBOOT=NO" > /etc/sysconfig/firstboot


echo 'add_drivers+="virtio-blk virtio-scsi"' > /etc/dracut.conf.d/add-virtio-modules.conf
dracut -f /boot/initramfs-`rpm -qa kernel|sed -e "s/kernel-//g"`.img `rpm -qa kernel|sed -e "s/kernel-//g"`
%end
