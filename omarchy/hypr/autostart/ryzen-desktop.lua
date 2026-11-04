-- Extra autostart processes.
-- OmaSession: reopen the last session at login
do local f = io.open("/home/dylan/.config/omarchy/plugins/brenoperucchi.omasession/bin/omasession") if f then f:close() o.launch_on_start("/home/dylan/.config/omarchy/plugins/brenoperucchi.omasession/bin/omasession restore --if-enabled") end end

-- Solaar: keeps the MX Vertical DPI button diverted and runs solaar/rules.yaml (push-to-talk).
o.launch_on_start("solaar --window=hide")
