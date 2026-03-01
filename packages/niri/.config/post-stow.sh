systemctl --user daemon-reload
systemctl --user enable swaybg.service

if systemctl --user is-active --quiet niri.service; then
	systemctl --user restart swaybg.service
fi
