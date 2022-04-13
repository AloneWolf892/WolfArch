echo "Input username"
read LOCAL_USERNAME
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

useradd -m $LOCAL_USERNAME
echo $LOCAL_USERNAME:$LOCAL_PASSWORD | chpasswd
echo "$LOCAL_USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$LOCAL_USERNAME

LOCAL_HOME=/home/$LOCAL_USERNAME

cd $LOCAL_HOME

git clone https://aur.archlinux.org/paru-bin.git
chown -R $LOCAL_USERNAME paru-bin
cd paru-bin
sudo -u $LOCAL_USERNAME makepkg -si --noconfirm
cd ..

sudo -u $LOCAL_USERNAME paru -S grub efibootmgr os-prober ntfs-3g networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools linux-headers bluez bluez-utils pulseaudio-bluetooth cups openssh zip unzip wget curl rsync qemu qemu-arch-extra virt-manager edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat xf86-video-amdgpu firewalld --noconfirm

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

sudo -u $LOCAL_USERNAME paru -S gnome gnome-extra gnome-themes-extra google-chrome chrome-gnome-shell gnome-shell-extension-installer ttf-ms-fonts steam discord grub-customizer visual-studio-code-bin kitty neofetch btop --noconfirm

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

sudo -u $LOCAL_USERNAME echo "# Lines configured by zsh-newuser-install                                                 " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "HISTFILE=~/.histfile                                                                      " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "HISTSIZE=6900                                                                             " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "SAVEHIST=6900                                                                             " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "bindkey -e                                                                                " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "# End of lines configured by zsh-newuser-install                                          " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "alias ll='ls -al --color'                                                                 " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "# The following lines were added by compinstall                                           " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "zstyle :compinstall filename '/home/akira.zshrc '                                         " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "                                                                                          " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh         " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh                 " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "                                                                                          " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "autoload -Uz compinit                                                                     " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "compinit                                                                                  " >> $LOCAL_HOME/.zshrc
sudo -u $LOCAL_USERNAME echo "# End of lines added by compinstall                                                       " >> $LOCAL_HOME/.zshrc

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
echo "sudo sed -i '/#Delete$/d' /etc/zsh/zprofile #Delete" >> /etc/zsh/zprofile

rm /etc/sudoers.d/$LOCAL_USERNAME
echo "$LOCAL_USERNAME ALL=(ALL) ALL" >> /etc/sudoers.d/$LOCAL_USERNAME