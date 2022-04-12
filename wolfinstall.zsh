CPU_THREADS=$(getconf _NPROCESSORS_ONLN)
sed -i "/^#ParallelDownloads/ c ParallelDownloads = $CPU_THREADS" /etc/pacman.conf
sed -i "/^#Color/ c Color" /etc/pacman.conf
timedatectl set-ntp true
pacman -Sy reflector dialog neofetch --noconfirm
reflector -c Spain -a 6 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy
neofetch
