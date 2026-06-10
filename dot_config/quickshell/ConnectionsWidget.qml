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

  property string wifi: "unknown"
  property string ssid: ""
  property string ethernet: "unknown"
  property string wireguard: "unknown"

  Process {
    id: networkProcess
    command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "getconnections"] // Ändra till absolut sökväg till ditt skript
        
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
          let d = JSON.parse(data);
          widgetRoot.wifi = d.wifi;
          widgetRoot.ssid = d.ssid;
          widgetRoot.ethernet = d.ethernet;
          widgetRoot.wireguard = d.wireguard;
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

  PanelWindow {
    id: testWidget
    implicitWidth: Screen.width 
    implicitHeight: Screen.height
    color: "transparent" 

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "test-hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.exclusiveZone: -1

    TapHandler {
      onTapped:
      widgetRoot.closeTestRequested()
    }

    Rectangle {
      id: topRec 
      width: 500 
      height: 1000
      color: "#F8F9E8"
      anchors.centerIn: parent
      //anchors.horizontalCenter: parent.horizontalCenter
      //anchors.top: parent.top
      //anchors.topMargin: 10
      focus: true
      radius: 12
      transformOrigin: Item.Top
      opacity: visible ? 1 : 0
      scale: visible ? 1 : 0
      visible: false 

      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      Keys.onEscapePressed: widgetRoot.closeTestRequested()

      Component.onCompleted: {
        topRec.visible = true 
      }


      //main heading
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
        text: wifi + ": " + ssid
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

      //Rimligtvis om du vill byta till ListView är att det är Row som byts ut till detta 
      ListView {
        id: optionList
        anchors.centerIn: parent
        width: 300; height: 610
        spacing: 2
        focus: true
        //orientation: ListView.Horizontal
        model: [
          { type: "internet", state: widgetRoot.wifi },
          { type: "firewall", state: widgetRoot.ethernet },
          { type: "vpn", state: widgetRoot.wireguard }
        ]
        delegate: Rectangle {
          id: listDelegate 
          width: 300; height: 200
          border.width: 1
          color: "black"
          radius: 12

          readonly property bool isSelected: ListView.isCurrentItem

          Text {
            color: listDelegate.isSelected ? "pink" : "white"
            anchors.centerIn: parent
            text: modelData.type + ": " + modelData.state
          }
        }
      }
      //ColorAnimation on color { from: "black"; to: "blue"; duration: 2000 }

    }
  }
}
