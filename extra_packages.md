# Extra Setup
- kwallet-pam required for kwallet integrations / remember passwords
- sddm-kcm required to configure sddm startup from kde settings
- pavucontrol required for audio in KDE (untested)
- kate basic text editor
- rsync require for my timeshift setup
- timeshift make system backups.
- zsh shell
```
sudo pacman -S --noconfirm  \
    kwallet-pam \
    sddm-kcm \
    pavucontrol \
    kate \
    rsync \
    timeshift \
    zsh
```

Change default shell to zsh
```
chsh -s /usr/bin/zsh
```

Install yay AUR helper
```
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```


- Add everything for my terminal, tmux, neovim setup
- https://github.com/jroddev/dot-files-2022
```
yay -S --noconfirm \
    tmux \
    alacritty \
    starship \
    neovim \
    ansible \
    nvim-packer-git \
    rust-analyzer \
    yaml-language-server \
    bash-language-server \
    ansible-language-server
```

- mix of other tools that I use
```
yay -S \
    ripgrep \
    btop \
    xclip \
    spectacle \
    nextcloud-client \
    keepassxc \
    libreoffice-still \
    thunderbird \
    joplin-desktop \
    rustup
```

- Setup an SSH key and ksshaskpass to remember the passphrase
```
sudo pacman -S openssl ksshaskpass
ssh-keygen -t ed25519 -C "jroddev@gmail.com"
# passphrase - f3930a85b300490f8b5e91ce602007d1
echo "[Desktop Entry]" > ~/.config/autostart/ssh-add.desktop
echo "Exec=ssh-add -q .ssh/id_ed25519" >> ~/.config/autostart/ssh-add.desktop
echo "Name=ssh-add" >> ~/.config/autostart/ssh-add.desktop
echo "Type=Application" >> ~/.config/autostart/ssh-add.desktop
echo "SSH_ASKPASS='/usr/bin/ksshaskpass'" >> ~/.zsh_preconfigure
echo "SSH_ASKPASS_REQUIRE=prefer" >> ~/.zsh_preconfigure
# new terminal session will request the ssh passphrase. Enter it and check remember
```

- Install Rust and rust-analyzer
```
sudo pacman -S rustup
rustup default stable
rustup component add rust-analyzer
```


## Other Notes
- nvim -> :PackerSync (need to run twice)
- I can run this headless, just need to find the command and add to script
- hibernate / sleep broken. Doesn't always resume
- apparmor / selinux firetools/firejail
- ufw / snitch
- clamav
- bleachbit - maybe just clean things manually
- command + shift + f -> fullscreen things (setup a shortcut)

