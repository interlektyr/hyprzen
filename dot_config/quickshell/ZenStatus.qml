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
  //visible: root.toggleConnectionStatus 

  property var typeStat: root.typeOfStat

  property var batIcon: ""
  property var wifiIcon: ""
  property real batteryLevel: 0
  property bool isCharging: false
  property real volLevel: 0
  property bool isMuted: false
  property bool isMicMuted: false
  property var activeWin: ""

  property string access: "ONLINE"
  property string wifi: "disconnected"
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
  property bool isOffline: false

  property string terminalOpt: "kitty"
  property var batIconColor: "#F5D098"
  property var volIconColor: {
    let val = statusBase.isMuted ? "#79867E" : "#A7C080"
    if (statusBase.isMuted) {
      return val
    }
    let level = Math.round(statusBase.volLevel * 100)
    if (level <= 100 && level >= 75) {
      val = "#E67E80"
    } else if (level <= 25 && level >= 1 ) {
      val = "#F5D098"
    }
    return val
  }
  property var wifiIconColor: "#F5D098" 

  property var powerEntries: [
      { id: "battery", statusIcon: statusBase.batIcon, statusText: Math.round(statusBase.batteryLevel * 100) + "%", shown: true, col: statusBase.batIconColor }
  ]

  property var volEntries: [
    { id: "volume", statusIcon: statusBase.isMuted ? "󰝛" : "", statusText: Math.round(statusBase.volLevel * 100) + "%", shown: true, col: statusBase.volIconColor },
    { id: "mick", statusIcon: "", statusText: "OFF", shown: statusBase.isMicMuted ? true : false, col: "#79867E" } 
  ]

  property var connEntries: [
    { id: "status", statusIcon: "󱜡", statusText: "OFFLINE", shown: statusBase.access == "ONLINE" ? false : true, col: "#E67E80" },
    { id: "cable", statusIcon: "󰈀", statusText: "PLUGGED", shown: statusBase.ethernetIp !== "none" ? true : false, col: "#A7C080" },
    { id: "wifi", statusIcon: statusBase.wifiIcon, statusText: statusBase.ssid, shown: statusBase.wifi == "connected" ? true : false, col: statusBase.wifiIconColor },
    { id: "fw", statusIcon: statusBase.fw == "DISABLED" ? "" : "󰒘", statusText: statusBase.fw == "DISABLED" ? "DOWN" : "UP", shown: true, col: statusBase.fw == "DISABLED" ? "#E67E80" : "#A7C080"},
    { id: "vpn", statusIcon: "󱐡", statusText: statusBase.wireguardLocation, shown: statusBase.wireguard == "DISABLED" ? false : true, col: "#A7C080" },
    { id: "blue", statusIcon: "󰂯", statusText: statusBase.bluetoothDevices.count > 0 ? "CONNECTED (" + statusBase.bluetoothDevices.count + " devices)" : "ON", shown: statusBase.bluetoothPower == "ON" ? true : false, col: "#A7C080" },
    { id: "torrent", statusIcon: "  ", statusText: " RUNNING (" + (statusBase.torrentDownloading ? "leaching" : "") + (statusBase.torrentDownloading && statusBase.torrentSeeding ? "/" : "") + (statusBase.torrentSeeding ? "seeding)" : "idle)"), shown: statusBase.torrentServer == "NOT RUNNING" ? false : true, col: "#A7C080" }
  ]

  property var idEntries: [
    { id: "title", statusIcon: "󰋽", statusText: statusBase.activeWinTitle, shown: true, col: "#E67E80"}
  ]

  Component.onCompleted: {
    batteryInfo.running = true;
    networkProcess.running = true;
  }

  Process {
    id: activeWinTitle
    command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "gettitleofactivewin"] 
    //hyprctl activewindow -j | jq -r ".title"
    running: statusBase.typeStat == "active_win"
    stdout: StdioCollector {
      onStreamFinished: {
        let t = data
        statusBase.activeWinTitle = t;

      }
    }
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

          let wifiIcon = ""
            if (statusBase.wifiStrenght > 0 && statusBase.wifiStrenght < 25) {
              statusBase.wifiIcon = "󰤟"
              statusBase.wifiIconColor = "#E67E80"
            } else if (statusBase.wifiStrenght >= 25 && statusBase.wifiStrenght <= 50) {
              statusBase.wifiIcon = "󰤢"
            } else if (statusBase.wifiStrenght > 50 && statusBase.wifiStrenght < 90) {
              statusBase.wifiIcon = "󰤥"
              statusBase.wifiIconColor = "#A7C080"
            } else {
              statusBase.wifiIcon = "󰤨"
              statusBase.wifiIconColor = "#A7C080"
            }
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
      }

      let batIcon = statusBase.isCharging ? "󰂄" : "" 
      let batTrans = Math.round(statusBase.batteryLevel * 100)
      if (batTrans > 90 && batTrans < 100) {
        statusBase.batIcon = "󰂂"
        statusBase.batIconColor == "#E67E80"
      } else if (batTrans == 100) {
        statusBase.batIcon = "󰁹"
        statusBase.batIconColor == "#E67E80"
        } else if (batTrans >= 80 && batTrans < 90) {
        statusBase.batIcon = "󰂁"
        statusBase.batIconColor == "#E67E80"
        } else if (batTrans >= 70 && batTrans < 80) {
        statusBase.batIcon = "󰂀"
        statusBase.batIconColor == "#E67E80"
        } else if (batTrans >= 60 && batTrans < 70) {
        statusBase.batIcon = "󰁿"
        statusBase.batIconColor == "#A7C080"
        } else if (batTrans >= 50 && batTrans < 60) {
        statusBase.batIcon = "󰁾"
        statusBase.batIconColor == "#A7C080"
        } else if (batTrans >= 40 && batTrans < 50) {
        statusBase.batIcon = "󰁽"
        statusBase.batIconColor == "#A7C080"
        } else if (batTrans >= 30 && batTrans < 40) {
        statusBase.batIcon = "󰁼"
        statusBase.batIconColor == "#F5D098"
        } else if (batTrans >= 20 && batTrans < 30) {
        statusBase.batIcon = "󰁻"
        statusBase.batIconColor == "#F5D098"
        } else if (batTrans >= 10 && batTrans < 20) {
        statusBase.batIcon = "󰁺"
        statusBase.batIconColor == "#E67E80"
        } else if (batTrans >= 0 && batTrans < 10) {
        statusBase.batIcon = "󰂃"
        statusBase.batIconColor == "#E67E80"
        }  
      }
    }
  }

  Process {
    id: volProc
    command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
    running: statusBase.typeStat == "volume" || statusBase.typeStat == "volume_change" ? true : false
    //running: true
    stdout: StdioCollector {
      onStreamFinished: {
        let output = text.trim();
        if (output === "") return;

        let parts = output.split(" ");
        if (parts.length >= 2) {
          statusBase.volLevel = parseFloat(parts[1]);
          statusBase.isMuted = output.includes("[MUTED]");
        }
      }
    }
  }

  Process {
    id: mickProc
    command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SOURCE@"]
    running: statusBase.typeStat == "volume" || statusBase.typeStat == "volume_change" ? true : false
    //running: true
    stdout: StdioCollector {
      onStreamFinished: {
        let output = text.trim();
        if (output === "") return;

        let parts = output.split(" ");
        if (parts.length >= 2) {
          statusBase.isMicMuted = output.includes("[MUTED]");
        }
      }
    }
  } 

  Timer {
    id: batteryTimer
    interval: 5000
    running: true
    repeat: true
    onTriggered: batteryInfo.running = true
  }

  Timer {
    id: connectionsTimer
    interval: 5000
    running: true
    repeat: true
    onTriggered: networkProcess.running = true
  }

  Timer {
    id: volumeTimer
    interval: 200
    running: statusBase.typeStat == "volume_change"
    repeat: true
    onTriggered: {
      volProc.running = true;
      mickProc.running = true;
    }
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
    width: componentRow.width + 15
    height: 35
    radius: 10
    //color: "#191d1f"
    color: "#1E2528"
    border.color: "pink"
    border.width: 0
    opacity: visible ? 1 : 0 
    scale: visible ? 1 : 0
    visible: statusBase.visible

    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

    //Component.onCompleted: {
    //statusRect.visible = true
    //}


    Row {
      id: componentRow
      anchors.centerIn: parent
      spacing: statusBase.typeStat == "battery" ? 5 : 10

      Repeater {
        model: {
          if (statusBase.typeStat == "volume" || statusBase.typeStat == "volume_change") {
            return statusBase.volEntries;
          } else if (statusBase.typeStat == "battery") {
            return statusBase.powerEntries;
          } else if (statusBase.typeStat == "connections") {
            return statusBase.connEntries;
          }
        }
        delegate: Row {
        visible: modelData.shown 
        spacing: modelData.id == "blue" ? 5 : 10
        Rectangle {
          id: statusIcon
          width: 20
          height: 20
          color: "transparent"

          Text {
            id: iconText
            anchors.centerIn: parent
            text: modelData.statusIcon 
            //color: "#F5D098"
            color: modelData.col
            font.family: "Work Sans"
            font.weight: Font.ExtraBold
            font.letterSpacing: 0
            font.pixelSize: 25
          }
        }

        Text {
          id: statusText
          text: modelData.statusText
          //text: "Test"
          color: "#F5D098"
          font.family: "DepartureMono Nerd Font Mono"
          font.weight: Font.ExtraBold
          font.letterSpacing: 0
          font.pixelSize: 18
        }
      }
      }
    }
  }
}
