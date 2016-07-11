# CHANGE ME
url --url=http://mirror.centos.org/altarch/7/os/aarch64/

auth --useshadow --passalgo=sha512


# Root password - probably should let firstboot change this
# NOTE: python -c 'import crypt; print crypt.crypt("centos", "$6$APXFUm4V8X9qPrF0")'
#rootpw --iscrypted $6$APXFUm4V8X9qPrF0$.8iDyE8oIKs0sYzyrkRaEJak3SaJhW0nRhKe4C5NsJqXreWA16a8fZlo2b/UDsuV39wczh7mRhxqgaoPSTxxY/

rootpw centos

# Time Zone - probably should let firstboot change this
timezone --utc --ntpservers=0.centos.pool.ntp.org,1.centos.pool.ntp.org,2.centos.pool.ntp.org,3.centos.pool.ntp.org  Etc/UTC

# Keyboard layout - probably something firstboot should configure
keyboard --xlayouts=us --vckeymap=us

repo --name="CentOS" --baseurl=http://mirror.centos.org/altarch/7/os/aarch64/ --cost=100
repo --name="Updates" --baseurl=http://mirror.centos.org/altarch/7/updates/aarch64/ --cost=100

shutdown

lang en_US.UTF-8
bootloader --location=mbr
clearpart --initlabel --all

part /boot/efi --size=100
part /boot     --size=400  --label=boot
part swap      --size=2000 --label=swap --asprimary
part /         --size=9400 --label=rootfs

%packages
@core
anaconda-core
bash-completion
vim-enhanced
emacs-nox
dracut-config-generic
git
autoconf
automake
binutils-devel
elfutils-devel
pesign
bison
flex
gcc
gcc-c++
gettext
libtool
make
patch
pkgconfig
redhat-rpm-config
rpm-build
byacc
cscope
ctags
diffstat
doxygen
elfutils
gcc-gfortran
git
indent
intltool
patchutils
kmod
hmaccalc
perl
m4
gzip
perl-Carp
diffutils
zlib-devel
newt-devel
python-devel
ncurses-devel
pciutils-devel
sh-utils
tar
gdisk
-iwl*firmware

%end


# NOTE: usually would use kickstart network directives, but that no worky on image builds, so HACK!
# This might be something firstboot could fix.
%post
cat <<EOF > '/etc/sysconfig/network-scripts/ifcfg-eth0'
NAME=eth0
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
NM_CONTROLLED=yes
EOF
%end
