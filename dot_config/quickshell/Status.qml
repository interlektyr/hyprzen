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
  margins.left: (Screen.width / 2) - (statusRect.width / 2) 
  color: "transparent"

  property var typeStat: "battery"
  property var batIcon: ""
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

      let batIcon = ""
      let batTrans = Math.round(statusBase.batteryLevel * 100)
      console.log(batTrans)
      if (batTrans > 90 && batTrans < 100) {
        statusBase.batIcon = "󰂂"
        } else if (batTrans > 80 && batTrans < 90) {
        statusBase.batIcon = "󰂁"
        } else if (batTrans > 70 && batTrans < 80) {
        statusBase.batIcon = "󰂀"
        } else if (batTrans > 60 && batTrans < 70) {
        statusBase.batIcon = "󰁿"
        } else if (batTrans > 50 && batTrans < 60) {
        statusBase.batIcon = "󰁾"
        } else if (batTrans > 40 && batTrans < 50) {
        statusBase.batIcon = "󰁽"
        } else if (batTrans > 30 && batTrans < 40) {
        statusBase.batIcon = "󰁼"
        } else if (batTrans > 20 && batTrans < 30) {
        statusBase.batIcon = "󰁻"
        } else if (batTrans > 10 && batTrans < 20) {
        statusBase.batIcon = "󰁺"
        } else if (batTrans > 0 && batTrans < 10) {
        statusBase.batIcon = "󰂃"
        } else {
        console.log("No")
        statusBase.batIcon = "󰁹"
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
    anchors.fill: statusRect
    radius: statusRect.radius 
    visible: false

  }

  MultiEffect {
    source: statusRect
    anchors.fill: statusRect
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
    id: statusRect
    width: statusText.width + statusIcon.width + (statusBase.typeStat == "battery" ? 20 : 40)
    height: 35
    radius: 10
    //color: "#191d1f"
    color: "#1E2528"
    border.color: "pink"
    border.width: 0

    Row {
      anchors.centerIn: parent
      spacing: statusBase.typeStat == "battery" ? 5 : 10 

      Rectangle {
        id: statusIcon
        width: 20
        height: 20
        color: "transparent"

        Text {
          anchors.centerIn: parent
          text: {
            let output = ""
            if (statusBase.typeStat == "volume") {
              output = statusBase.isMuted ? "󰝛" : ""
            } else if (statusBase.typeStat == "battery") {
              output = statusBase.isCharging ? "󰂄" : statusBase.batIcon
              //output = "󰁹"
            }
            return output
          }
          //text: (statusBase.isCharging ? "󰂄" : "󰁹")
          color: "#F5D098"
          //font.family: "DepartureMono Nerd Font Mono"
          //font.pixelSize: 15
          font.family: "Work Sans"
          font.weight: Font.ExtraBold
          font.letterSpacing: 0
          font.pixelSize: 25
          //font.weight: Font.ExtraBold
          //font.letterSpacing: -5
        }
      }

      Text {
        id: statusText
        //anchors.centerIn: parent 
        //text: "BAT " + Math.round(statusBase.batteryLevel * 100) + "% (" + (statusBase.isCharging ? "Charging" : "Discharging") + ")" 
        //text: "BAT"
        //text: statusBase.isMuted ? "VOL MUTED" : "VOL " + Math.round(statusBase.volLevel * 100) + "%"
        text: {
          let output = ""
          if (statusBase.typeStat == "volume") {
            output = statusBase.isMuted ? "MUTED" : Math.round(statusBase.volLevel * 100) + "%" 
          } else if (statusBase.typeStat == "battery") {
            output = Math.round(statusBase.batteryLevel * 100) + "%"  
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
}
