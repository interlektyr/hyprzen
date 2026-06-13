import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Quickshell.Io

Scope {
  id: widgetRoot
  
  signal closeTestRequested()

  property string access: "ONLINE"
  property string wifi: "unknown"
  property string ssid: ""
  property string wifiIp: ""
  property string eto: ""
  property string ethernet: "unknown"
  property string ethernetIp: ""
  property string wireguard: "DISABLED"
  property string wireguardLocation: ""
  property string wireguardIp: ""
  property string fw: "DOWN"
  property string torrentServer: "NOT RUNNING"
  property bool torrentDownloading: false
  property bool torrentSeeding: false

  Process {
    id: networkProcess
    command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "getconnections"] // Ändra till absolut sökväg till ditt skript
        
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
         let d = JSON.parse(data);
          widgetRoot.access = d.access;
          widgetRoot.wifi = d.wifi;
          widgetRoot.ssid = d.ssid;
          widgetRoot.wifiIp = d.wifi_ip;
          widgetRoot.eto = d.eto;
          widgetRoot.ethernet = d.ethernet;
          widgetRoot.ethernetIp = d.ethernet_ip;
          widgetRoot.wireguard = d.wireguard;
          widgetRoot.wireguardLocation = d.wireguard_location;
          widgetRoot.wireguardIp = d.wireguard_ip;
          widgetRoot.fw = d.fw;
          widgetRoot.torrentServer = d.torrent_server;
      }
    }
  }

  Timer {
    interval: 5000 // Uppdatera var 5:e sekund
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!networkProcess.running) {
        networkProcess.running = true;
        }
      }
  }

  QtObject {
    id: connectionOpt 

    property var connectionEntries: [
      { title: "internet", desc: "open nmtui" },         
      { title: "firewall", desc: "open tufw" },
      { title: "vpn", desc: "open mullvad-vpn" },
      { title: "bluetooth", desc: "launch bluetooth" },
      { title: "torrents", desc: torrentDesc() }
    ]

    property var connectionInfo: [
      { title: "internet", state: internetText(), itemColor: internetColor() },
      { title: "firewall", state: widgetRoot.fw + "<br> Uncomplicated Firewall", itemColor: firewallColor() },
      { title: "vpn", state: vpnText(), itemColor: vpnColor() },
      { title: "bluetooth", state: "inactive", itemColor: "white" },
      { title: "torrents", state: widgetRoot.torrentServer + torrentText(), itemColor: "white" }
    ]
  }

  function internetText() {
    var output = "OFFLINE";
      if (widgetRoot.wifi == "connected" && widgetRoot.ethernet != "connected") {
          output = widgetRoot.access + "<br> WIFI " + widgetRoot.ssid + "<br>" + widgetRoot.wifiIp
      }  
    return output
  }

  function internetColor() {
    var titleColor = "white"
    if (widgetRoot.access == "ONLINE") {
      titleColor = "#CAE0A7"
    } else {
      titleColor = "#F57F82"
    }
    return titleColor
  }

  function firewallColor() {
    var titleColor = "white"
    if (widgetRoot.fw == "UP") {
      titleColor = "#CAE0A7"
    } else {
      titleColor = "#F57F82"
    }
    return titleColor
  }

  function vpnText() {
    var output = "DISABLED"
    if (widgetRoot.wireguard == "ENABLED") {
      output = widgetRoot.wireguard + "<br>" + widgetRoot.wireguardLocation + "<br>" + widgetRoot.wireguardIp
    }
    return output
  }

  function vpnColor() {
    var titleColor = "white"
    if (widgetRoot.wireguard == "ENABLED") {
      titleColor = "#CAE0A7"
    } else {
      titleColor = "#F57F82"
    }
    return titleColor
  }

  function torrentText() {
    var output = "" 
    if (widgetRoot.torrentServer == "RUNNING") {
      if (widgetRoot.torrentDownloading && !widgetRoot.torrentSeeding) {
        output = "<br> Downloading"
      } else if (!widgetRoot.torrentDownloading && widgetRoot.torrentSeeding) {
        output = "<br> Seeding" 
      } else if (widgetRoot.torrentDownloading && widgetRoot.torrentSeeding) {
        output = "<br> Downloading <br> Seeding"
      } else if (!widgetRoot.torrentDownloading && !widgetRoot.torrentSeeding) {
        output = "<br> Idle"
      }
    }
    return output
  }

  function torrentDesc() {
    var output = "start transmission and launch tremc"
    if (widgetRoot.torrentServer == "RUNNING") {
      output = "launch tremc or kill transmission"
    }
    return output
  }

  PanelWindow {
    id: testWidget
    implicitWidth: Screen.width 
    implicitHeight: Screen.height
    color: "transparent" 

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "connections-hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.exclusiveZone: -1

    TapHandler {
      onTapped:
      widgetRoot.closeTestRequested()
    }

    Rectangle {
      id: conRec 
      width: 800 
      height: 500
      color: "#F8F9E8"
      anchors.centerIn: parent
      //anchors.horizontalCenter: parent.horizontalCenter
      //anchors.top: parent.top
      //anchors.topMargin: 10
      //focus: true
      radius: 12
      transformOrigin: Item.Top
      opacity: visible ? 1 : 0
      scale: visible ? 1 : 0
      visible: false
      clip: true

      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      Keys.onEscapePressed: widgetRoot.closeTestRequested()

      Component.onCompleted: {
        conRec.visible = true
      }

      //ColorAnimation on color { from: "black"; to: "blue"; duration: 2000 }
      //
 
      RowLayout {
        id: mainRow
        anchors.fill: parent
        spacing: 2 

        Rectangle {
          id: optionRec
          Layout.preferredWidth: parent.width / 2
          Layout.fillHeight: true
          color: "transparent"
          radius: 12

          ListView {
            id: optView
            //anchors.fill: parent
            //anchors.centerIn: parent
            //anchors.horizontalCenter: optionsRec.horizontalCenter
            //anchors.verticalCenter: optionsRec.verticalCenter
            width: parent.width
            height: contentHeight
            anchors.left: parent.left
            anchors.bottom: parent.bottom 
            anchors.leftMargin: 20
            anchors.bottomMargin: optionRec.height / 2
            model: connectionOpt.connectionEntries
            clip: true
            focus: true 
            currentIndex: 0 
            spacing: 5
            highlightMoveDuration: 200
            highlightFollowsCurrentItem: true
            delegate: Item {
              id: optItemDelegate 
              width: optView.width
              height: 20

              readonly property bool isSelected: ListView.isCurrentItem 

              Row {
                anchors.fill: parent 
                anchors.leftMargin: 0 
                spacing: 1

                Text {
                  width: 20
                  text: ">"
                  color: "pink"
                  font.pixelSize: 26
                  font.family: "DepartureMono Nerd Font Mono"
                  visible: optItemDelegate.isSelected
                  //Layout.preferredWidth: 20
                  anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                  text: modelData.title
                  color: isSelected ? "pink" : "black"
                  font.pixelSize: 26 
                  font.family: "DepartureMono Nerd Font Mono"
                  verticalAlignment: Text.AlignVCenter
                  horizontalAlignment: Text.AlignHCenter
                  height: parent.height
                }
              }
            } 
            //Component.onCompleted: forceActiveFocus()
            //onActiveFocusChanged: console.log("Focus: ", activeFocus)
            Keys.onPressed: (event) => {
              //pkill -f -3 transmission-daemon för att stänga ner transmission
                if (event.key === Qt.Key_Down) {
                  event.accepted = true;
                  if (optView.count > 0) {
                    optView.currentIndex = (optView.currentIndex + 1) % optView.count;
                    infoList.currentIndex = optView.currentIndex;
                  }
                //console.log("Ner");
              }
              else if (event.key === Qt.Key_Up) {
                event.accepted = true;
                if (optView.count > 0) {
                  optView.currentIndex = (optView.currentIndex - 1 + optView.count) % optView.count
                  infoList.currentIndex = optView.currentIndex;
                }
                //console.log("Up");
              }
            }
          } //ListView
        }

        Rectangle {
          id: infoRec
          Layout.preferredWidth: parent.width / 2
          Layout.fillHeight: true
          color: "transparent"
          radius: 12

          ListView {
            id: infoList
            anchors.right: parent.right
            //anchors.centerIn: parent
            anchors.top: parent.top
            anchors.topMargin: 100
            anchors.rightMargin: 20
            implicitWidth: parent.width
            implicitHeight: contentHeight
            //height: 300
            spacing: 2 
            model: connectionOpt.connectionInfo
            delegate: Rectangle {
              width: infoRec.width
              height: isSelected ? infocon.contentHeight + 25 : 25
              color: "#272E33"
              radius: 12
              clip: true

              readonly property bool isSelected: ListView.isCurrentItem

              Text {
                font.pixelSize: 20
                font.family: "Work Sans"
                font.weight: Font.ExtraBold
                //color: "white"
                color: modelData.itemColor 
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 2 
                anchors.rightMargin: 5
                text: modelData.title
              }

              Text {
                id: infocon
                font.pixelSize: 15
                font.family: "DepartureMono Nerd Font Mono"
                color: "white"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2 
                anchors.leftMargin: 5 
                anchors.left: parent.left
                text: modelData.state
                visible: isSelected
              }
            }
          }
        }
      }

      Text {
        text: "connections"
        color: "#272E33"
        font.pixelSize: 50
        font.family: "Work Sans"
        font.weight: Font.Bold
        font.letterSpacing: -3 
        anchors.top: parent.top
        anchors.right: parent.right 
        anchors.topMargin: -5 
        anchors.rightMargin: 10

        OpacityAnimator on opacity {
          from: 0; to: 1; duration: 150 
          running: true
        }
      }

      Text {
        text: "[esc] quit [enter] " + connectionOpt.connectionEntries[optView.currentIndex].desc          
        //text: "[\uf062/\uf063] navigation [enter] launch [esc] quit"
        color: "#1e2528"
        font.pixelSize: 15
        font.family: "DepartureMono Nerd Font Mono"
        anchors.bottom: parent.bottom
        anchors.left: parent.left 
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        font.letterSpacing: -1

        OpacityAnimator on opacity {
          from: 0; to: 1; duration: 150 
          running: true
        }
      }
    }
  }
}
