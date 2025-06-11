#!/bin/bash  
# Install dependencies  
sudo pacman -S --needed fish wezterm rofi starship  

# Clone repo and stow configs  
git clone https://github.com/chenxing-dev/dotfiles.git ~/dotfiles  
cd ~/dotfiles  
stow -vt ~ */  