CPU_THREADS=$(getconf _NPROCESSORS_ONLN)
sed -i "/^#ParallelDownloads/ c ParallelDownloads = $CPU_THREADS" /etc/pacman.conf
sed -i "/^#Color/ c Color" /etc/pacman.conf
timedatectl set-ntp true
pacman -Sy reflector --noconfirm
reflector -c Spain -a 6 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy dialog neofetch --noconfirm
neofetch

lsblk

PS3="Select the root partition: "
COLUMNS=12
select rootpartition in $(lsblk -n --output NAME -l)
do
        echo "$rootpartition will be used as the root partition"
        mkfs.btrfs /dev/$rootpartition -f
        mount /dev/$rootpartition /mnt
        break
done

PS3="Select the boot partition: "
COLUMNS=12
select bootpartition in $(lsblk -n --output NAME -l)
do
        echo "$bootpartition will be used as the boot/efi partition"
        mkdir /mnt/boot
        mkdir /mnt/boot/efi
        mount /dev/$bootpartition /mnt/boot/efi
        break
done

PS3="Select the swap partition: "
COLUMNS=12
select swappartition in $(lsblk -n --output NAME -l)
do
        echo "$swappartition will be used as the swap partition"
        break
done

PS3="Select your processor brand: "
COLUMNS=12
select proctype in amd intel virtualmachine
do
    echo "ucode for $proctype will be installed"
    break
done

if [[ $proctype -eq "intel" ]]
then pacstrap /mnt base linux linux-firmware vim nano git intel-ucode reflector base-devel rust
elif [[ $proctype -eq "amd" ]]
then pacstrap /mnt base linux linux-firmware vim nano git amd-ucode reflector base-devel rust
elif [[ $proctype -eq "virtualmachine" ]]
then pacstrap /mnt base linux linux-firmware vim nano git reflector base-devel rust
fi

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

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
echo root:password | chpasswd

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ..

paru -S grub efibootmgr os-prober ntfs-3g networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools linux-headers bluez bluez-utils pulseaudio-bluetooth cups openssh google-chrome chrome-gnome-shell zip wget curl qemu qemu-arch-extra virt-manager bridge-utils rsync --noconfirm

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCHLINUX
grub-mkconfig -o /boot/grub/grub.cfg

mkdir Downloads
cd Downloads
curl -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip
unzip CascadiaCode.zip
cd CascadiaCode