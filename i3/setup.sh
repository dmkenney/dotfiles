#!/bin/bash

if [ -e "$HOME/.config/i3/screen-setup.sh" ]; then
	$HOME/.config/i3/screen-setup.sh
else
	echo "No custom screen setup"
fi
