# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
#session_root "~/Projects/setup-and-dotfiles"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "Setup Script & Dotfiles"; then
	window_root "~/setup-scripts/"
	new_window "Setup Script"
	split_v 15
	select_pane 1
	run_cmd "nvim"

	window_root "~/dotfiles/"
	new_window "Dotfiles"
	split_v 15
	select_pane 1
	run_cmd "nvim"

	# Select the default active window on session creation.
	select_window 1

fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
