CPU_THREADS=$(getconf _NPROCESSORS_ONLN)
sed -i "s/^#ParallelDownloads/ c ParallelDownloads = $CPU_THREADS" /etc/pacman.conf
sed -i "s/^#Color/ c Color" /etc/pacman.conf