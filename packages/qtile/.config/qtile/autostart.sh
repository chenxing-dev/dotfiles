#!/bin/sh

picom &
fcitx5 &
dunst &

# Start the startpage server at http://localhost:8000
python -m http.server 8000 --directory ~/dotfiles/startpage/ &
