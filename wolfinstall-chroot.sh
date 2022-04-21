chsh -s /bin/zsh root

echo "Input username"
read LOCAL_USERNAME
echo "Input Full Name (Only for display at logon)"
read LOCAL_FULLNAME
echo "Input password"
read LOCAL_PASSWORD
echo "Input Hostname"
read LOCAL_HOSTNAME

reflector -c Spain -a 6 --sort rate --save /etc/pacman.d/mirrorlist

ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime 
hwclock --systohc

timedatectl set-ntp true

CPU_THREADS=$(getconf _NPROCESSORS_ONLN)
sed -i "/^#ParallelDownloads/ c ParallelDownloads = $CPU_THREADS" /etc/pacman.conf
sed -i "/^#Color/ c Color" /etc/pacman.conf
sed -i "93s/.//" /etc/pacman.conf
sed -i "94s/.//" /etc/pacman.conf

pacman -Syyy

useradd -D -s /bin/zsh

sed -i "178s/.//" /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo $LOCAL_HOSTNAME >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $LOCAL_HOSTNAME.localdomain   $LOCAL_HOSTNAME" >> /etc/hosts
echo root:$LOCAL_PASSWORD | chpasswd

sed -i "s/rwh/frwh/" /etc/login.defs

useradd -m $LOCAL_USERNAME
echo $LOCAL_USERNAME:$LOCAL_PASSWORD | chpasswd
echo "$LOCAL_USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$LOCAL_USERNAME

sudo -u $LOCAL_USERNAME chfn -f $LOCAL_FULLNAME

LOCAL_HOME=/home/$LOCAL_USERNAME

cd $LOCAL_HOME

git clone https://aur.archlinux.org/paru-bin.git
chown -R $LOCAL_USERNAME paru-bin
cd paru-bin
sudo -u $LOCAL_USERNAME makepkg -si --noconfirm
cd ..

sudo -u $LOCAL_USERNAME paru -S grub efibootmgr os-prober ntfs-3g networkmanager network-manager-applet wireless_tools wpa_supplicant iwd dialog mtools dosfstools linux-headers bluez bluez-utils pulseaudio-bluetooth cups openssh zip unzip wget curl rsync rclone qemu qemu-arch-extra virt-manager edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat xf86-video-amdgpu firewalld man --noconfirm

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

usermod -aG libvirt $LOCAL_USERNAME

sudo -u $LOCAL_USERNAME mkdir Downloads
cd Downloads
sudo -u $LOCAL_USERNAME mkdir CaskaydiaCove
cd CaskaydiaCove
sudo -u $LOCAL_USERNAME wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip
sudo -u $LOCAL_USERNAME unzip CascadiaCode.zip

mkdir -p $LOCAL_HOME/.local/share/fonts
cp $LOCAL_HOME/Downloads/CaskaydiaCove/* $LOCAL_HOME/.local/share/fonts
chown -R $LOCAL_USERNAME:$LOCAL_USERNAME $LOCAL_HOME/.local

fc-cache

sudo -u $LOCAL_USERNAME paru -S gnome gnome-extra gnome-themes-extra google-chrome chrome-gnome-shell gnome-shell-extension-installer ttf-ms-fonts steam discord lutris grub-customizer visual-studio-code-bin kitty neofetch btop gparted --noconfirm
sudo -u $LOCAL_USERNAME paru -S wine-stable wine-gecko wine-mono --noconfirm
sudo -u $LOCAL_USERNAME paru -S dina-font tamsyn-font ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji --noconfirm
systemctl enable gdm.service --now

sudo -u $LOCAL_USERNAME mkdir $LOCAL_HOME/.config
sudo -u $LOCAL_USERNAME mkdir $LOCAL_HOME/.config/kitty

sudo -u $LOCAL_USERNAME echo "font_family               CaskaydiaCove NF" >> $LOCAL_HOME/.config/kitty/kitty.conf
sudo -u $LOCAL_USERNAME echo "font_size                 14              " >> $LOCAL_HOME/.config/kitty/kitty.conf
sudo -u $LOCAL_USERNAME echo "cursor                    #00ffcc         " >> $LOCAL_HOME/.config/kitty/kitty.conf
sudo -u $LOCAL_USERNAME echo "cursor_shape              block           " >> $LOCAL_HOME/.config/kitty/kitty.conf
sudo -u $LOCAL_USERNAME echo "hide_window_decorations   yes             " >> $LOCAL_HOME/.config/kitty/kitty.conf
sudo -u $LOCAL_USERNAME echo "shell_integration         no-cursor       " >> $LOCAL_HOME/.config/kitty/kitty.conf
sudo -u $LOCAL_USERNAME echo "window_padding_width      10              " >> $LOCAL_HOME/.config/kitty/kitty.conf

chown $LOCAL_USERNAME:$LOCAL_USERNAME $LOCAL_HOME/.config/kitty/kitty.conf
cp /root/WolfArch/.zshrc $LOCAL_HOME/.zshrc
cp /root/WolfArch/.p10k.zsh $LOCAL_HOME/.p10k.zsh

chown $LOCAL_USERNAME:$LOCAL_USERNAME $LOCAL_HOME/.zshrc
chown $LOCAL_USERNAME:$LOCAL_USERNAME $LOCAL_HOME/.p10k.zsh

sudo -u $LOCAL_USERNAME git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $LOCAL_HOME/powerlevel10k
sudo -u $LOCAL_USERNAME echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> $LOCAL_HOME/.zshrc

chown $LOCAL_USERNAME:$LOCAL_USERNAME $LOCAL_HOME/.zshrc

cd $LOCAL_HOME/Downloads
sudo -u $LOCAL_USERNAME git clone https://github.com/xenlism/Grub-themes
cd $LOCAL_HOME/Downloads/Grub-themes/xenlism-grub-arch-1080p/
. ./install.sh

sudo -u $LOCAL_USERNAME gnome-shell-extension-installer 3357 --yes
sudo -u $LOCAL_USERNAME gnome-shell-extension-installer 3357 --yes

echo "gnome-extensions enable material-shell@papyelgringo #Delete" >> /etc/zsh/zprofile
echo "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' #Delete" >> /etc/zsh/zprofile
echo "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' #Delete" >> /etc/zsh/zprofile
echo "gsettings set org.gnome.desktop.input-sources sources \"[('xkb', 'es+winkeys')]\" #Delete" >> /etc/zsh/zprofile
echo "gsettings set org.gnome.desktop.peripherals.touchpad click-method 'areas'" >> /etc/zsh/zprofile
echo "gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true" >> /etc/zsh/zprofile
echo "sed -i \"/#Delete$/d\" /etc/zsh/zprofile #Delete" >> /etc/zsh/zprofile

ln -s $LOCAL_HOME/.zshrc /root/.zshrc
ln -s $LOCAL_HOME/.p10k.zsh /root/.p10k.zsh
ln -s $LOCAL_HOME/powerlevel10k /root/powerlevel10k

paru -S openssl mpv aria2 ffmpeg --noconfirm
paru -S ani-cli-git --noconfirm

rm /etc/sudoers.d/$LOCAL_USERNAME
echo "$LOCAL_USERNAME ALL=(ALL) ALL" >> /etc/sudoers.d/$LOCAL_USERNAME
