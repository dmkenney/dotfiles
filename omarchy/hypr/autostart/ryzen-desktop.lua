-- Extra autostart processes.
-- RGB (fans, cooler, RAM, GPU): load the OpenRGB profile after the devices are ready.
o.launch_on_start("sh -c 'sleep 10 && openrgb -p rainbow'")
