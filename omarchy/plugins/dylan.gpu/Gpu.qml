import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Laptop dedicated GPU: highlighted while the NVIDIA GPU is powered, dim while it is
// off. Click to switch with Omarchy's own toggle (supergfxctl Hybrid <-> Integrated,
// asks to confirm, then reboots). Hidden on machines without a battery or an NVIDIA GPU.
BarWidget {
  id: root
  moduleName: "dylan.gpu"

  // "none" (hide), "on", "off", or "pending" (switched, waiting for the reboot).
  property string gpuState: "none"
  property string mode: ""

  function refresh() {
    if (!stateProc.running) stateProc.running = true
  }

  function toggle() {
    if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation omarchy-toggle-hybrid-gpu")
  }

  visible: gpuState !== "none"
  implicitWidth: visible ? button.implicitWidth : 0
  implicitHeight: button.implicitHeight

  // Prints "<present|absent> <mode>". The NVIDIA display controller is gone from the
  // PCI bus in Integrated mode; mode is Hybrid until supergfxd.conf says otherwise.
  Process {
    id: stateProc
    command: ["bash", "-c", "ls /sys/class/power_supply | grep -q '^BAT' || { echo none; exit; }; " +
      "nv=absent; for d in /sys/bus/pci/devices/*; do " +
      "[[ $(<$d/vendor) == 0x10de && $(<$d/class) == 0x03* ]] && nv=present; done; " +
      "mode=$(sed -n 's/.*\"mode\": *\"\\([A-Za-z]*\\)\".*/\\1/p' /etc/supergfxd.conf 2>/dev/null); " +
      "[[ $nv == absent && -z $mode ]] && { echo none; exit; }; echo \"$nv ${mode:-Hybrid}\""]
    stdout: StdioCollector {
      onStreamFinished: {
        var parts = this.text.trim().split(" ")
        root.mode = parts[1] || ""
        if (parts[0] !== "present" && parts[0] !== "absent") root.gpuState = "none"
        else if (parts[0] === "present") root.gpuState = root.mode === "Integrated" ? "pending" : "on"
        else root.gpuState = root.mode === "Integrated" ? "off" : "pending"
      }
    }
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰢮"
    active: root.gpuState === "on"
    tooltipText: root.gpuState === "on" ? "NVIDIA GPU on (Hybrid). Click to turn it off."
      : root.gpuState === "off" ? "NVIDIA GPU off (Integrated). Click to turn it on."
      : "NVIDIA GPU switch to " + root.mode + " waits for a reboot."
    onPressed: root.toggle()
  }
}
