CPU_THREADS=$(getconf _NPROCESSORS_ONLN)
sed -i "/^#ParallelDownloads/ c ParallelDownloads = $CPU_THREADS" /etc/pacman.conf
sed -i "/^#Color/ c Color" /etc/pacman.conf
timedatectl set-ntp true
pacman -Sy reflector --noconfirm
reflector -c Spain -a 6 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy dialog neofetch --noconfirm
neofetch

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
select bootpartition in $(lsblk -n --output NAME -l)
do
        echo "$bootpartition will be used as the boot/efi partition"
        mkdir /mnt/boot
        mkdir /mnt/boot/efi
        mount /dev/$bootpartition /mnt/boot/efi
        break
done

PS3="Select the swap partition: "
select swappartition in $(lsblk -n --output NAME -l)
do
        echo "$swappartition will be used as the swap partition"
        break
done