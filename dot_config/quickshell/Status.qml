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
  visible: true

  property var typeStat: "connections"
  property var batIcon: ""
  property var wifiIcon: ""
  property real batteryLevel: 0
  property bool isCharging: false
  property real volLevel: 0
  property bool isMuted: false

  property string access: "ONLINE"
  property string wifi: "unknown"
  property string ssid: ""
  property string wifiIp: ""
  property real wifiStrenght: 0
  property string eto: ""
  property string ethernet: "disconnected"
  property string ethernetIp: "none"
  property string wireguard: "DISABLED"
  property string wireguardLocation: ""
  property string wireguardIp: ""
  property string fw: "DOWN"
  property string torrentServer: "NOT RUNNING"
  property bool torrentDownloading: false
  property bool torrentSeeding: false
  property string bluetoothPower: "OFF"
  property var bluetoothDevices: []

  property string terminalOpt: "kitty"

  Component.onCompleted: {
    batteryInfo.running = true;
    networkProcess.running = true;
    //statusBase.visible = true;
  }

  Process {
    id: networkProcess
    command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "getconnections"] // Ändra till absolut sökväg till ditt skript
    running: true    
    stdout: StdioCollector {
      onStreamFinished: {
         let d = JSON.parse(data);
          statusBase.access = d.access;
          statusBase.wifi = d.wifi;
          statusBase.ssid = d.ssid;
          statusBase.wifiIp = d.wifi_ip;
          statusBase.wifiStrenght = d.wifi_signal;
          statusBase.eto = d.eto;
          statusBase.ethernet = d.ethernet;
          statusBase.ethernetIp = d.ethernet_ip;
          statusBase.wireguard = d.wireguard;
          statusBase.wireguardLocation = d.wireguard_location;
          statusBase.wireguardIp = d.wireguard_ip;
          statusBase.fw = d.fw;
          statusBase.torrentServer = d.torrent_server;
          statusBase.bluetoothPower = d.bluetooth_power;
          statusBase.bluetoothDevices = d.bluetooth_devices;
      }
    }
  }

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
      if (batTrans > 90 && batTrans < 100) {
        statusBase.batIcon = "󰂂"
        //du måste lägga till typ >= eller om det är =>
        } else if (batTrans >= 80 && batTrans < 90) {
        statusBase.batIcon = "󰂁"
        } else if (batTrans >= 70 && batTrans < 80) {
        statusBase.batIcon = "󰂀"
        } else if (batTrans >= 60 && batTrans < 70) {
        statusBase.batIcon = "󰁿"
        } else if (batTrans >= 50 && batTrans < 60) {
        statusBase.batIcon = "󰁾"
        } else if (batTrans >= 40 && batTrans < 50) {
        statusBase.batIcon = "󰁽"
        } else if (batTrans >= 30 && batTrans < 40) {
        statusBase.batIcon = "󰁼"
        } else if (batTrans >= 20 && batTrans < 30) {
        statusBase.batIcon = "󰁻"
        } else if (batTrans >= 10 && batTrans < 20) {
        statusBase.batIcon = "󰁺"
        } else if (batTrans >= 0 && batTrans < 10) {
        statusBase.batIcon = "󰂃"
        } else {
        console.log("No")
        statusBase.batIcon = "󰁹"
      }

      let wifiIcon = ""
      if (statusBase.wifiStrenght > 0 && statusBase.wifiStrenght < 25) {
        statusBase.wifiIcon = "󰤟"
      } else if (statusBase.wifiStrenght >= 25 && statusBase.wifiStrenght <= 50) {
        statusBase.wifiIcon = "󰤢"
      } else if (statusBase.wifiStrenght > 50 && statusBase.wifiStrenght < 90) {
        statusBase.wifiIcon = "󰤥"
      } else {
        statusBase.wifiIcon = "󰤨"
      }
      }
    }
  }

  Process {
    id: volProc
    command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
    running: statusBase.typeStat == "volume" ? true : false
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
    id: batteryTimer
    interval: 5000 // Uppdatera var 5:e sekund
    running: true
    repeat: true
    onTriggered: batteryInfo.running = true
  }

  Timer {
    id: connectionsTimer
    interval: 5000 // Uppdatera var 5:e sekund
    running: true
    repeat: true
    onTriggered: networkProcess.running = true
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
    width: statusText.width + statusIcon.width + (statusBase.typeStat == "connections" ? statusIcons.width + statusIcons.width + statusTexts.width + statusIcont.width + statusTextt.width : 0) + (statusBase.typeStat == "connections" ? statusBase.ethernetIp !== "none" ? statusIconw.width + statusTextw.width : 0 : 0) + (statusBase.typeStat == "battery" ? 20 : statusBase.typeStat == "connections" ? 50 : 40)
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
            console.log("ethernet: " + statusBase.ethernet)
            console.log("et_ip: " + statusBase.ethernetIp)
            if (statusBase.typeStat == "volume") {
              output = statusBase.isMuted ? "󰝛" : ""
            } else if (statusBase.typeStat == "battery") {
              output = statusBase.isCharging ? "󰂄" : statusBase.batIcon
              //output = "󰁹"
            } else if (statusBase.typeStat == "connections") {
              output = statusBase.access == "ONLINE" ? statusBase.wifiIcon : "󰤮"
            }
            return output
          }
          //text: (statusBase.isCharging ? "󰂄" : "󰁹")
          //color: "#F5D098"
          color: {
            let output = ""
            if (statusBase.typeStat == "connections") {
              if (statusBase.wifiIcon == "󰤟") {
                output = "#F5D098" 
              } else {
                output = "#A7C080" 
              }
            } else {
              output = "#F5D098" 
            }
            return output
          }
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
          } else if (statusBase.typeStat == "connections") {
            output = statusBase.access == "ONLINE" ? "ONLINE" : "OFFLINE"
          }
          return output
        }
        color: "#F5D098"
        //font.family: "DepartureMono Nerd Font Mono"
        //font.pixelSize: 15
        font.family: statusBase.typeStat == "connections" ? "DepartureMono Nerd Font Mono" : "Work Sans"
        font.weight: Font.ExtraBold
        //font.family: "DepartureMono Nerd Font Mono"
        font.letterSpacing: 0
        font.pixelSize: statusBase.typeStat == "connections" ? 18 : 20
        //font.weight: Font.ExtraBold
        //font.letterSpacing: -5 
      }

      Rectangle {
        id: statusIconw
        width: 20
        height: 20
        color: "transparent"
        visible: {
          let output = false
          if (statusBase.typeStat == "connections" && statusBase.ethernetIp !== "none") {
            output = true 
          }
          return output
        }
        Text {
          anchors.centerIn: parent
          text: "󰈁"
          color: "#A7C080" 
          //"#F5D098"
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
        id: statusTextw
        visible: {
          let output = false
          if (statusBase.typeStat == "connections" && statusBase.ethernetIp !== "none") {
            output = true 
          }
          return output
        }
        //anchors.centerIn: parent 
        //text: "BAT " + Math.round(statusBase.batteryLevel * 100) + "% (" + (statusBase.isCharging ? "Charging" : "Discharging") + ")" 
        //text: "BAT"
        //text: statusBase.isMuted ? "VOL MUTED" : "VOL " + Math.round(statusBase.volLevel * 100) + "%"
        text: "PLUGGED"
        color: "#F5D098"
        //font.family: "DepartureMono Nerd Font Mono"
        //font.pixelSize: 15
        font.family: statusBase.typeStat == "connections" ? "DepartureMono Nerd Font Mono" : "Work Sans"
        font.weight: Font.ExtraBold
        //font.family: "DepartureMono Nerd Font Mono"
        font.letterSpacing: 0
        font.pixelSize: statusBase.typeStat == "connections" ? 18 : 20
        //font.weight: Font.ExtraBold
        //font.letterSpacing: -5 
      }

      Rectangle {
        id: statusIcons
        width: 20
        height: 20
        color: "transparent"
        visible: statusBase.typeStat == "connections" ? true : false

        Text {
          anchors.centerIn: parent
          text: statusBase.fw == "DISABLED" ? "" : "󰒘"
          color: statusBase.fw == "DISABLED" ? "#E67E80" : "#A7C080" 
          //"#F5D098"
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
        id: statusTexts
        //anchors.centerIn: parent 
        //text: "BAT " + Math.round(statusBase.batteryLevel * 100) + "% (" + (statusBase.isCharging ? "Charging" : "Discharging") + ")" 
        //text: "BAT"
        //text: statusBase.isMuted ? "VOL MUTED" : "VOL " + Math.round(statusBase.volLevel * 100) + "%"
        text: statusBase.fw == "DISABLED" ? "DOWN" : "UP"  
        color: "#F5D098"
        //font.family: "DepartureMono Nerd Font Mono"
        //font.pixelSize: 15
        font.family: statusBase.typeStat == "connections" ? "DepartureMono Nerd Font Mono" : "Work Sans"
        font.weight: Font.ExtraBold
        //font.family: "DepartureMono Nerd Font Mono"
        font.letterSpacing: 0
        font.pixelSize: 18
        //font.weight: Font.ExtraBold
        //font.letterSpacing: -5
        visible: statusBase.typeStat == "connections" ? true : false
      }

      Rectangle {
        id: statusIcont
        width: 20
        height: 20
        color: "transparent"
        visible: statusBase.typeStat == "connections" ? true : false

        Text {
          anchors.centerIn: parent
          text: statusBase.wireguard == "DISABLED" ? "󱐢" : "󱐡"
          color: statusBase.wireguard == "DISABLED" ? "#E67E80" : "#A7C080"
          //color: "#F5D098"
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
        id: statusTextt
        //anchors.centerIn: parent 
        //text: "BAT " + Math.round(statusBase.batteryLevel * 100) + "% (" + (statusBase.isCharging ? "Charging" : "Discharging") + ")" 
        //text: "BAT"
        //text: statusBase.isMuted ? "VOL MUTED" : "VOL " + Math.round(statusBase.volLevel * 100) + "%"
        text: statusBase.wireguard == "DISABLED" ? "DISABLED" : "ENABLED"  
        color: "#F5D098"
        //font.family: "DepartureMono Nerd Font Mono"
        //font.pixelSize: 15
        font.family: statusBase.typeStat == "connections" ? "DepartureMono Nerd Font Mono" : "Work Sans"
        font.weight: Font.ExtraBold
        //font.family: "DepartureMono Nerd Font Mono"
        font.letterSpacing: 0
        font.pixelSize: 18
        //font.weight: Font.ExtraBold
        //font.letterSpacing: -5
        visible: statusBase.typeStat == "connections" ? true : false
      }



    }
  }
}
