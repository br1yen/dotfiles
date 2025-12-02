#!/bin/bash

mkdir -p ~/.config

ln -sf ~/dotfiles/i3 ~/.config/i3
ln -sf ~/dotfiles/picom ~/.config/picom
ln -sf ~/dotfiles/kitty ~/.config/kitty
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/ranger ~/.config/ranger
ln -sf ~/dotfiles/i3blocks ~/.config/i3blocks
ln -sf ~/dotfiles/fonts ~/.config/fonts

echo "Dotfiles installed!"
