import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell
import Quickshell.Io

PanelWindow {
  id: statusBase
  implicitWidth: Screen.width
  implicitHeight: 70
  anchors.left: true
  anchors.top: true
  margins.top: 5 
  margins.left: (Screen.width / 2) - (clockRect.width / 2) 
  color: "transparent"

  property var typeStat: "battery"
  property real batteryLevel: 0
  property bool isCharging: false
  property real volLevel: 0
  property bool isMuted: false

  Process {
    id: batteryInfo
    command: ["bash", "-c", "echo $(cat /sys/class/power_supply/BAT0/capacity) $(cat /sys/class/power_supply/BAT0/status)"]
    running: true
    stdout: StdioCollector {
    onStreamFinished: {
      let output = text.trim();
      if (output === "") return;

      let parts = output.split(" ");
      if (parts.length >= 2) {
        statusBase.batteryLevel = parseInt(parts[0]) / 100;
        statusBase.isCharging = (parts[1] === "Charging" || parts[1] === "Full");
                
        console.log("Hämtat via StdioCollector:", parts[0] + "%, " + parts[1]);
        }
      }
    }
  }

  Process {
    id: volProc
    command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        let output = text.trim(); // Exempel: "Volume: 0.45" eller "Volume: 0.45 [MUTED]"
        if (output === "") return;

        let parts = output.split(" ");
        if (parts.length >= 2) {
          statusBase.volLevel = parseFloat(parts[1]);
          statusBase.isMuted = output.includes("[MUTED]");
        }
      }
    }
  }

  Timer {
    interval: 5000 // Uppdatera var 5:e sekund
    running: true
    repeat: true
    onTriggered: batteryInfo.running = true
  }

  Rectangle {
    id: shadowMask
    anchors.fill: clockRect
    radius: clockRect.radius 
    visible: false

  }

  MultiEffect {
    source: clockRect
    anchors.fill: clockRect
    shadowEnabled: true
    autoPaddingEnabled: false
    paddingRect: Qt.rect(20, 20, 40, 30)
    shadowBlur: 0.6
    shadowVerticalOffset: 5 
    shadowHorizontalOffset: 5
    maskEnabled: true
    maskSource: shadowMask

  }

  Rectangle {
    id: clockRect
    width: clock.width + 20
    height: 35
    radius: 10
    //color: "#191d1f"
    color: "#1E2528"
    border.color: "pink"
    border.width: 0

    Text {
      id: clock
      anchors.centerIn: parent 
      //text: "BAT " + Math.round(statusBase.batteryLevel * 100) + "% (" + (statusBase.isCharging ? "Charging" : "Discharging") + ")" 
      //text: "BAT"
      //text: statusBase.isMuted ? "VOL MUTED" : "VOL " + Math.round(statusBase.volLevel * 100) + "%"
      text: {
        let output = ""
        if (statusBase.typeStat == "volume") {
          output = statusBase.isMuted ? "VOL MUTED" : "VOL " + Math.round(statusBase.volLevel * 100) + "%" 
        } else if (statusBase.typeStat == "battery") {
          output = "BAT " + Math.round(statusBase.batteryLevel * 100) + "% (" + (statusBase.isCharging ? "Charging" : "Discharging") + ")"  
        }
        return output
      }
      color: "#F5D098"
      //font.family: "DepartureMono Nerd Font Mono"
      //font.pixelSize: 15
      font.family: "Work Sans"
      font.weight: Font.ExtraBold
      font.letterSpacing: 0
      font.pixelSize: 20
      //font.weight: Font.ExtraBold
      //font.letterSpacing: -5 
    }
  }
}
