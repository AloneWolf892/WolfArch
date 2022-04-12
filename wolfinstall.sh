CPU_THREADS=$(getconf _NPROCESSORS_ONLN)
sed -i "/^#ParallelDownloads/ c ParallelDownloads = $CPU_THREADS" /etc/pacman.conf
sed -i "/^#Color/ c Color" /etc/pacman.conf