LOCAL_USERNAME=akira
LOCAL_PASSWORD=akira
LOCAL_HOME=/home/$LOCAL_USERNAME

reflector -c Spain -a 6 --sort rate --save /etc/pacman.d/mirrorlist

ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime 
hwclock --systohc

CPU_THREADS=$(getconf _NPROCESSORS_ONLN)
sed -i "/^#ParallelDownloads/ c ParallelDownloads = $CPU_THREADS" /etc/pacman.conf
sed -i "/^#Color/ c Color" /etc/pacman.conf
sed -i "93s/.//" /etc/pacman.conf
sed -i "94s/.//" /etc/pacman.conf

pacman -Syyy

sed -i "178s/.//" /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
HOSTNAME="ARCHTEST"
echo $HOSTNAME >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain   $HOSTNAME" >> /etc/hosts
echo root:$LOCAL_PASSWORD | chpasswd

useradd -m $LOCAL_USERNAME
echo $LOCAL_USERNAME:$LOCAL_PASSWORD | chpasswd
echo "$LOCAL_USERNAME ALL=(ALL) ALL" >> /etc/sudoers.d/$LOCAL_USERNAME

cd $LOCAL_HOME

git clone https://aur.archlinux.org/paru-bin.git
chown -R $LOCAL_USERNAME paru-bin
cd paru-bin
sudo -u $LOCAL_USERNAME makepkg -si --noconfirm
cd ..

sudo -u $LOCAL_USERNAME paru -S grub efibootmgr os-prober ntfs-3g networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools linux-headers bluez bluez-utils pulseaudio-bluetooth cups openssh zip unzip wget curl rsync qemu qemu-arch-extra virt-manager edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft xf86-video-amdgpu --noconfirm

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCHLINUX
grub-mkconfig -o /boot/grub/grub.cfg

sed -i "63s/.//" /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable reflector.timer
systemctl enable libvirtd

mkdir Downloads
cd Downloads
mkdir CaskaydiaCove
cd CaskaydiaCove
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip
unzip CascadiaCode.zip

mkdir /usr/local/share/fonts
mkdir /usr/local/share/fonts/ttf
mkdir /usr/local/share/fonts/ttf/CaskaydiaCove
chmod 555 /usr/local/share/fonts/
chmod 555 /usr/local/share/fonts/ttf/
cp /home/akira/Downloads/CaskaydiaCove /usr/local/share/fonts/ttf/ -r
chmod 555 /usr/local/share/fonts/ttf/CaskaydiaCove
chmod 444 /usr/local/share/fonts/ttf/CaskaydiaCove/*
fc-cache

