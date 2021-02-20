#!/bin/bash

# First update after installation
sudo pacman -Syyu
# Yay pkg manager
sudo pacman -Syu yay
# Give pacman/yay some colors
sudo sed -s -r -i 's/^#?Color/Color/' /etc/pacman.conf

systemctl enable sshd.service
systemctl enable systemd-timesyncd.service

# Multi 3.5 jack - enable microphone support
cat <<EOF > /etc/modprobe.d/alsa.conf
options snd-hda-intel model=dell-headset-multi
EOF

# Reboot

# Latest kernel
mhwd-kernel -i linux510
mhwd-kernel -r linux59

# Reboot

# General tools
yay -Syu autoconf automake binutils conky dnsutils fakeroot gcc gsmartcontrol icedtea-web ipcalc lm_sensors lshw m4 make meld networkmanager-fortisslvpn network-manager-sstp nmap patch pkgconf sstp-client tcpdump vim
yay -Syu transmission-gtk transmission-remote-gtk

# LibreOffice pack
yay -Syu libreoffice-fresh libreoffice-fresh-en-gb

# To allow ASDM access:
# edit /usr/lib/jvm/java-8-openjdk/jre/lib/security/java.security and remove MD5 from jdk.jar.disabledAlgorithms=

# Dev services
yay -Syu apache mariadb mod_fcgid mongodb-bin mongodb-tools-bin mysql-workbench php-fpm robo3t-bin

# Setup mariadb
sudo mysql_install_db --user=mysql --ldata=/var/lib/mysql

sudo mkdir -p /etc/httpd/conf/vhosts
sudo cat <<EOF | tee /etc/httpd/conf/extra/php-fpm.conf
DirectoryIndex index.php index.html
<FilesMatch \.php$>
SetHandler "proxy:unix:/run/php-fpm/php-fpm.sock|fcgi://localhost/"
</FilesMatch>
EOF

# As root:
sed -s -i -r 's/#?LoadModule proxy_module /LoadModule proxy_module /g' /etc/httpd/conf/httpd.conf
sed -s -i -r 's/#?LoadModule proxy_fcgi_module /LoadModule proxy_fcgi_module /g' /etc/httpd/conf/httpd.conf
echo "Include conf/extra/php-fpm.conf" >> /etc/httpd/conf/httpd.conf
echo "Include conf/vhosts/*.conf" >> /etc/httpd/conf/httpd.conf

# Dev tools and services
yay -Syu ansible aws-cli code freerdp git inkscape jq nodejs python-pylint remmina terraform vault
sudo pip3 install hvac

# Pidgin skype plugin
# yay -Syu gmime libpurple intltool pidgin-sipe

# Extra software from AUR
yay -Syu amazon-workspaces-bin brave-bin google-chrome mattermost-desktop-bin postman-bin spotify teams zoom

# Citrix Receiver
yay -Syu icaclient

# Virtualization
yay -Syu virtualbox virtualbox-ext-oracle virtualbox-guest-iso
sudo -gpasswd -a vboxusers robertas
sudo cat <<EOF > /etc/udev/rules.d/60-vboxdrv.rules
SUBSYSTEM=="usb_device", ACTION=="add", RUN+="/usr/share/virtualbox/VBoxCreateUSBNode.sh $major $minor vboxusers"
SUBSYSTEM=="usb", ACTION=="add", ENV{DEVTYPE}=="usb_device", RUN+="/usr/share/virtualbox/VBoxCreateUSBNode.sh $major $minor vboxusers"
EOF

reboot


# Cleanup unused files and dependencies
yay -R $(yay -Qdtq)

# Unused packages
yay -Rcs mesa-demos xfburn thunderbird xfcs4-notes-plugin

