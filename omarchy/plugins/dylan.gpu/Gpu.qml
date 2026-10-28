import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import qs.Commons as Commons

// Laptop graphics: Integrated (NVIDIA GPU powered off) or NVIDIA (Hybrid). The bar
// icon is highlighted while the NVIDIA GPU is on; the panel shows both modes with
// the current one highlighted, and switching is live (bin/gpu-mode, supergfxctl).
// Hidden on machines without a battery or supergfxd.
Panel {
  id: root
  moduleName: "dylan.gpu"
  ipcTarget: "dylan.gpu"
  manageIpc: false

  property string mode: ""            // "Integrated" | "Hybrid" | ""
  property string power: ""           // supergfxctl -S: active, suspended, off, ...
  property bool available: false
  property bool switching: false
  property string message: ""
  property int cursorIndex: 0
  property bool cursorActive: false

  readonly property var modes: [
    { id: "Integrated", label: "Integrated", icon: "󰘚" },
    { id: "Hybrid", label: "NVIDIA", icon: "󰢮" }
  ]
  readonly property bool nvidiaOn: mode === "Hybrid" && power !== "off"

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function setMode(next) {
    if (!next || next === mode || switching) return
    switching = true
    message = "Switching to " + (next === "Hybrid" ? "NVIDIA" : "Integrated") + "…"
    setProc.command = [Quickshell.env("HOME") + "/.local/bin/gpu-mode", "set", next]
    setProc.running = true
  }

  function parseStatus(raw) {
    var parts = String(raw || "").trim().split(/\s+/)
    if (parts[0] === "none" || parts[0] === "") {
      available = false
      return
    }
    available = true
    mode = parts[0]
    power = parts[1] || ""
  }

  ShellIpc {
    target: "dylan.gpu"

    function open() { root.open() }
    function close() { root.close() }
    function toggle() { root.toggle() }
  }

  onOpenedChanged: {
    if (opened) {
      message = ""
      refresh()
      cursorIndex = mode === "Hybrid" ? 1 : 0
      cursorActive = false
    }
  }

  visible: available
  implicitWidth: available ? button.implicitWidth : 0
  implicitHeight: available ? button.implicitHeight : 0

  Process {
    id: statusProc
    command: [Quickshell.env("HOME") + "/.local/bin/gpu-mode", "status"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.parseStatus(text) }
  }

  Process {
    id: setProc
    stdout: StdioCollector { id: setOut; waitForEnd: true }
    onExited: function(exitCode) {
      root.switching = false
      var out = String(setOut.text || "").trim()
      root.message = exitCode === 0 ? out : (out || "Switch failed (exit " + exitCode + ")")
      root.refresh()
    }
  }

  Timer { interval: root.opened || root.switching ? 2000 : 30000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰢮"
    active: root.nvidiaOn
    tooltipText: root.nvidiaOn ? "NVIDIA GPU on" : "NVIDIA GPU off"
    onPressed: root.toggle()
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened && root.available
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(320))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: PanelKeyCatcher {
      anchors.fill: parent
      implicitHeight: column.implicitHeight
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        root.cursorIndex = (root.cursorIndex + 1) % root.modes.length
      }
      onActivateRequested: if (root.cursorActive) root.setMode(root.modes[root.cursorIndex].id)
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(10)

        PanelSectionHeader {
          text: "Graphics"
          foreground: root.bar.foreground
          fontFamily: root.bar.fontFamily
        }

        Row {
          id: modeRow
          width: parent.width
          spacing: Style.space(6)
          readonly property real cellWidth: (width - spacing * (root.modes.length - 1)) / root.modes.length

          Repeater {
            model: root.modes
            Button {
              required property var modelData
              required property int index
              width: modeRow.cellWidth
              iconText: modelData.icon
              iconSize: Style.font.title
              text: modelData.label
              fontSize: Style.font.bodySmall
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
              horizontalPadding: Style.spacing.controlPaddingX
              verticalPadding: Style.spacing.controlPaddingY + Style.space(2)
              bordered: true
              enabled: !root.switching
              active: root.mode === modelData.id
              hasCursor: root.cursorActive && root.cursorIndex === index
              onClicked: root.setMode(modelData.id)
              onHovered: function(h) {
                if (h) {
                  root.cursorActive = true
                  root.cursorIndex = index
                }
              }
            }
          }
        }

        Text {
          width: parent.width
          wrapMode: Text.Wrap
          textFormat: Text.PlainText
          color: root.bar.foreground
          opacity: 0.6
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.bodySmall
          text: root.message || ("NVIDIA GPU: " + (root.power || "unknown"))
        }
      }
    }
  }
}
