# Change the default shell for root to be zsh
chsh -s /bin/zsh root

# Update time and date info
timedatectl set-ntp true

# Get info from the user to setup, well, the user
echo "Input username"
read LOCAL_USERNAME
echo "Input Full Name (Only for display at logon)"
read LOCAL_FULLNAME
echo "Input password"
read LOCAL_PASSWORD

# Get the hostname 
echo "Input Hostname"
read LOCAL_HOSTNAME

# Enable the english US locale
sed -i "178s/.//" /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Change the default shell for new users to be zsh (Yes I like zsh)
useradd -D -s /bin/zsh

# Set the root passoword to be the same as the user password
echo root:$LOCAL_PASSWORD | chpasswd

# Make the user able to set it's assigned Full Name to be displayed in GDM 
sed -i "s/rwh/frwh/" /etc/login.defs

# Add the local user
useradd -m $LOCAL_USERNAME

# Set the password for the local user
echo $LOCAL_USERNAME:$LOCAL_PASSWORD | chpasswd

# Set the user to be able to execute the sudo command without a password prompt
echo "$LOCAL_USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$LOCAL_USERNAME

# Get information about the number of logical cores that the CPU has
CPU_THREADS=$(getconf _NPROCESSORS_ONLN)

# Set up pacman.conf using the number of threads available
sed -i "/^#ParallelDownloads/ c ParallelDownloads = $CPU_THREADS" /etc/pacman.conf
sed -i "/^#Color/ c Color" /etc/pacman.conf
sed -i "93s/.//" /etc/pacman.conf
sed -i "94s/.//" /etc/pacman.conf

# Change the Full Name assigned to the local user 
sudo -u $LOCAL_USERNAME chfn -f $LOCAL_FULLNAME

# Update the mirrorlist to have the best servers 
reflector -c Spain -a 6 --sort rate --save /etc/pacman.d/mirrorlist

# Set up the timezone for the machine
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime 
hwclock --systohc

# Update time and date info
timedatectl set-ntp true

# Force update the repos
pacman -Syyy

# Set the hostname for the machine
echo $LOCAL_HOSTNAME >> /etc/hostname

# Set up the hosts file
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $LOCAL_HOSTNAME.localdomain   $LOCAL_HOSTNAME" >> /etc/hosts

# Install rust because ferris
sudo -u $LOCAL_USERNAME curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > $LOCAL_HOME/rustup-init.sh 
chown $LOCAL_USERNAME:$LOCAL_USERNAME $LOCAL_HOME/rustup-init.sh
sudo -u $LOCAL_USERNAME sh $LOCAL_HOME/rustup-init.sh -y

# Variable that holds the home directory for the local user
LOCAL_HOME=/home/$LOCAL_USERNAME

# Set the current working directory for the rest of the script
cd $LOCAL_HOME

# Download and install the paru aur helper (It's written in rust :D)
git clone https://aur.archlinux.org/paru-bin.git
chown -R $LOCAL_USERNAME paru-bin
cd paru-bin
sudo -u $LOCAL_USERNAME makepkg -si --noconfirm
cd ..

# Paru needs to be executed by a user and not root
# First batch of installed apps 
# Summary: bootloader, filesystems, networking, bluetooth, audio, virtualization
sudo -u $LOCAL_USERNAME paru -S grub efibootmgr os-prober ntfs-3g networkmanager network-manager-applet wireless_tools wpa_supplicant iwd dialog mtools dosfstools linux-headers bluez bluez-utils pulseaudio-bluetooth cups openssh zip unzip wget curl rsync rclone qemu qemu-arch-extra virt-manager edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat xf86-video-amdgpu firewalld man vifm --noconfirm

# Leave activated the virtual network for QEMU virtual machines
virsh net-autostart default

# First grub install to autocreate all the files
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCHLINUX
grub-mkconfig -o /boot/grub/grub.cfg

# This enables os-prober so it can detect other OS on the system
sed -i "63s/.//" /etc/default/grub

# New grub config now that os-prober is enabled
grub-mkconfig -o /boot/grub/grub.cfg


# Adding the local user to the libvirt group so that qemu and virt-manager stop crying
usermod -aG libvirt $LOCAL_USERNAME

# Download the CaskaydiaCove font cuz I love it
sudo -u $LOCAL_USERNAME mkdir Downloads
cd Downloads
sudo -u $LOCAL_USERNAME mkdir CaskaydiaCove
cd CaskaydiaCove
sudo -u $LOCAL_USERNAME wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip
sudo -u $LOCAL_USERNAME unzip CascadiaCode.zip

# Install the CaskaydiaCove font cuz I love it
mkdir -p $LOCAL_HOME/.local/share/fonts
cp $LOCAL_HOME/Downloads/CaskaydiaCove/* $LOCAL_HOME/.local/share/fonts
chown -R $LOCAL_USERNAME:$LOCAL_USERNAME $LOCAL_HOME/.local
fc-cache

# Second batch of installed apps
# Summary: gnome, gdm, chrome, steam, discord, vscode, obsidian, kitty terminal
sudo -u $LOCAL_USERNAME paru -S gdm gnome-control-center gnome-font-viewer gnome-themes-extra nautilus adwaita-icon-theme gnome-desktop-common google-chrome chrome-gnome-shell gnome-shell-extension-installer ttf-ms-fonts steam discord lutris grub-customizer visual-studio-code-bin kitty neofetch btop gparted obsidian dos2unix joycond --noconfirm

# Try to install wine in some sense cuz it will failt due to conflict packages but whatever
sudo -u $LOCAL_USERNAME paru -S wine-stable wine-gecko wine-mono --noconfirm

# Install a bunch of fonts so that internet browsing works properly, I don't like seeing a bunch of squares instead of actual words
sudo -u $LOCAL_USERNAME paru -S dina-font tamsyn-font ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji --noconfirm

# Basic system services enabled so they run at start
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable reflector.timer
systemctl enable libvirtd
systemctl enable gdm.service
systemctl enable joycond

# Create the kitty terminal config directory and copy the file from the repo
sudo -u $LOCAL_USERNAME mkdir $LOCAL_HOME/.config
sudo -u $LOCAL_USERNAME mkdir $LOCAL_HOME/.config/kitty
cp /root/WolfArch/Config/kitty.conf $LOCAL_HOME/.config/kitty/kitty.conf
mkdir /root/.config
mkdir /root/.config/kitty

# Copy the zsh configs 
cp /root/WolfArch/Config/.zshrc $LOCAL_HOME/.zshrc
cp /root/WolfArch/Config/.p10k.zsh $LOCAL_HOME/.p10k.zsh

# Copy the configs for vim
sudo -u $LOCAL_USERNAME mkdir $LOCAL_HOME/.config/nvim
cp /root/WolfArch/Config/init.vim $LOCAL_HOME/.config/nvim/init.vim

# Download the powerlevel10k plugin so the terminal is prettier
sudo -u $LOCAL_USERNAME git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $LOCAL_HOME/powerlevel10k

# Download and install grub theme so it looks cool
cd $LOCAL_HOME/Downloads
sudo -u $LOCAL_USERNAME git clone https://github.com/xenlism/Grub-themes
cd $LOCAL_HOME/Downloads/Grub-themes/xenlism-grub-arch-1080p/
. ./install.sh

# This installs material-shell and yes it needs to be run twice because for some reason the first time fails but the second time works perfectly fine.
sudo -u $LOCAL_USERNAME gnome-shell-extension-installer 3357 --yes
sudo -u $LOCAL_USERNAME gnome-shell-extension-installer 3357 --yes

# Adding gnome configs to the zprofile file so that the commands are run on login of any user
# Summary: Enable material-shell; enable dark-theme; enable spanish keyboard; config the touchpad so it makes sense.
echo "gnome-extensions enable material-shell@papyelgringo #Delete" >> /etc/zsh/zprofile
echo "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' #Delete" >> /etc/zsh/zprofile
echo "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' #Delete" >> /etc/zsh/zprofile
echo "gsettings set org.gnome.desktop.input-sources sources \"[('xkb', 'es+winkeys')]\" #Delete" >> /etc/zsh/zprofile
echo "gsettings set org.gnome.desktop.peripherals.touchpad click-method 'areas'" >> /etc/zsh/zprofile
echo "gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true" >> /etc/zsh/zprofile
echo "sed -i \"/#Delete$/d\" /etc/zsh/zprofile #Delete" >> /etc/zsh/zprofile

# Setting the ownership of configs to the user
chown $LOCAL_USERNAME:$LOCAL_USERNAME $LOCAL_HOME/.config/kitty/kitty.conf
chown $LOCAL_USERNAME:$LOCAL_USERNAME $LOCAL_HOME/.zshrc
chown $LOCAL_USERNAME:$LOCAL_USERNAME $LOCAL_HOME/.p10k.zsh
chown $LOCAL_USERNAME:$LOCAL_USERNAME $LOCAL_HOME/.config/nvim/init.vim
chwon -R $LOCAL_USERNAME:$LOCAL_USERNAME $LOCAL_HOME/powerlevel10k

# Creating some symlinks so that the root user also has the cool configs enabled.
ln -s $LOCAL_HOME/.zshrc /root/.zshrc
ln -s $LOCAL_HOME/.p10k.zsh /root/.p10k.zsh
ln -s $LOCAL_HOME/.config/nvim/init.vim /root/.config/nvim/init.vim
ln -s $LOCAL_HOME/powerlevel10k /root/powerlevel10k
ln -s $LOCAL_HOME/.config/kitty/kitty.conf /root/.config/kitty/kitty.conf

# Install the way to watch anime in the command line
sudo -u $LOCAL_USERNAME paru -S openssl mpv aria2 ffmpeg openvpn celluloid --noconfirm
sudo -u $LOCAL_USERNAME paru -S ani-cli-git --noconfirm

# Since this is written on a windows machine we need to sanitize the config files.
dos2unix $LOCAL_HOME/.zshrc
dos2unix $LOCAL_HOME/.p10k.zsh
dos2unix $LOCAL_HOME/.config/nvim/init.vim
dos2unix $LOCAL_HOME/.config/kitty/kitty.conf

# Set the local user to be able to use sudo commands but with password prompt
rm /etc/sudoers.d/$LOCAL_USERNAME
echo "$LOCAL_USERNAME ALL=(ALL) ALL" >> /etc/sudoers.d/$LOCAL_USERNAME
