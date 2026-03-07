#!/bin/bash

rm -rf ~/.config/alacritty
ln -sf ~/dotfiles/alacritty ~/.config/alacritty

rm -rf ~/.config/nvim
ln -sf ~/dotfiles/nvim ~/.config/nvim

ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/picom/picom.conf ~/.config/picom.conf
ln -sf ~/dotfiles/i3/config ~/.config/i3/config
ln -sf ~/dotfiles/i3/setup-script.sh ~/.config/i3/setup.sh
ln -sf ~/dotfiles/i3/.Xmodmap ~/.Xmodmap
ln -sf ~/dotfiles/mise/config.toml ~/.config/mise/config.toml
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/zsh/.p10k.zsh ~/.p10k.zsh
ln -sf ~/dotfiles/backgrounds/ ~/.config/
ln -sf ~/dotfiles/gtk/.gtkrc-2.0 ~/.gtkrc-2.0

# Tailscale setup
if ! command -v tailscale &> /dev/null; then
  sudo pacman -S --noconfirm tailscale
fi
sudo systemctl enable --now tailscaled
echo "Run 'sudo tailscale up' to authenticate if not already connected"

# sshd setup
if ! command -v sshd &> /dev/null; then
  sudo pacman -S --noconfirm openssh
fi
sudo cp ~/dotfiles/systemd/sshd_config /etc/ssh/sshd_config
sudo mkdir -p /etc/systemd/system/sshd.service.d
sudo cp ~/dotfiles/systemd/sshd.service.d/tailscale.conf /etc/systemd/system/sshd.service.d/
sudo systemctl daemon-reload
sudo systemctl enable --now sshd

# Run the command if the file exists
if [ -f ./personal/install.sh ]; then
  ./personal/install.sh
fi
