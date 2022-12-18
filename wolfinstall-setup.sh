# Get the number of threads on the CPU
CPU_THREADS=$(getconf _NPROCESSORS_ONLN)

# Set the number of parallel downloads on pair with the number of threads
sed -i "/^#ParallelDownloads/ c ParallelDownloads = $CPU_THREADS" /etc/pacman.conf
sed -i "/^#Color/ c Color" /etc/pacman.conf

# Sincronize time
timedatectl set-ntp true

# Get the best servers for spain
reflector -c Spain -a 6 --sort rate --save /etc/pacman.d/mirrorlist

# Install these because of utility, neofetch is cool
pacman -Sy dialog neofetch --noconfirm

# Cool kid
neofetch

# Select the root partition for the OS
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

# Select the /boot/efi partition
lsblk
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

# Select the swap partition
lsblk
PS3="Select the swap partition: "
COLUMNS=12
select swappartition in $(lsblk -n --output NAME -l)
do
        echo "$swappartition will be used as the swap partition"
        mkswap /dev/$swappartition
        swapon /dev/$swappartition
        break
done

# Select the processor brand
PS3="Select your processor brand: "
COLUMNS=12
select proctype in amd intel virtualmachine
do
    echo "ucode for $proctype will be installed"
    break
done

# Update pacman keys
pacman-key --init
pacman-key --populate

# Change the installer based on the processor selected
# This installs the base OS to the selected root partition
if [[ $proctype -eq "intel" ]]
then pacstrap /mnt base linux linux-firmware neovim nano git intel-ucode reflector base-devel zsh zsh-syntax-highlighting zsh-autosuggestions
elif [[ $proctype -eq "amd" ]]
then pacstrap /mnt base linux linux-firmware neovim nano git amd-ucode reflector base-devel zsh zsh-syntax-highlighting zsh-autosuggestions
elif [[ $proctype -eq "virtualmachine" ]]
then pacstrap /mnt base linux linux-firmware neovim nano git reflector base-devel zsh zsh-syntax-highlighting zsh-autosuggestions
fi

# I still don't know why this is necessary
genfstab -U /mnt >> /mnt/etc/fstab

# Copy the repo folder to the home of root to keep using the files within it
cp WolfArch /mnt/root/ -r

# Change the root to the mounted partition and start the other script
arch-chroot /mnt /bin/zsh $HOME/WolfArch/wolfinstall-chroot.sh

# Dismount the drives and reboot
umount -a
# reboot
