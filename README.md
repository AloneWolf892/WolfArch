## Summary
Just a script to automatically install my archlinux enviroment, this will mount selected partitions and install my things with some configs, it's not much but it's mine :D

## Recommendations
Select your keyboard layout to use, archinstaller by default has the us layout selected.
In my case i have a spanish keyboard so I use
```zsh
loadkeys es
```

## Instalation Requirements

1. Verify internet connection: if on wifi you can use [iwctl](https://wiki.archlinux.org/title/Iwd#iwctl) to connect to a wireless network.

2. Partition Ecosystem: This will install on GPT disks and the partitions must be already present. It will let you select which partitions to use for the mountpoints
    1. /boot/efi
    2. /
    3. SWAP

3. Getting the script: First we need to install git by
```zsh
pacman -Sy git
```
And then we do the following
```zsh
git clone https://github.com/AloneWolf892/WolfArch
```

4. Running the script: For this we just do
```zsh
. ./WolfArch/wolfinstall.zsh
```

## License
[MIT](https://choosealicense.com/licenses/mit/)