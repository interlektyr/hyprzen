import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import Quickshell.Services.UPower

//BATTERY

Scope {
  id: widgetRoot
  
  signal closeBRequested()
  signal activityBDetected()

  PanelWindow {
    id: testWidget
    implicitWidth: Screen.width 
    implicitHeight: Screen.height
    color: "transparent" 

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "battery-hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.onDemand
    WlrLayershell.exclusiveZone: -1

    TapHandler {
      onTapped:
      widgetRoot.closeBRequested()
    }

    Rectangle {
      id: mainContainer 
      width: 450 
      height: 280
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
      antialiasing: true
      clip: true

      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      Keys.onEscapePressed: widgetRoot.closeBRequested()

      //property real batteryLevel: 0.40
      
      // Skapa egenskaper som är "fria" att uppdateras
      property real batteryLevel: 0
      property bool isCharging: false

      Process {
        id: batteryInfo
        command: ["bash", "-c", "echo $(cat /sys/class/power_supply/BAT0/capacity) $(cat /sys/class/power_supply/BAT0/status)"]
        running: true
        stdout: StdioCollector {
        // I Quickshell triggas onFinished när kommandot (cat) kört klart
        // Då finns all data tillgänglig i propertyn 'text'
        onStreamFinished: {
          let output = text.trim();
          if (output === "") return;

          let parts = output.split(" ");
          if (parts.length >= 2) {
                // Uppdatera våra properties
                mainContainer.batteryLevel = parseInt(parts[0]) / 100;
                mainContainer.isCharging = (parts[1] === "Charging" || parts[1] === "Full");
                
                console.log("Hämtat via StdioCollector:", parts[0] + "%, " + parts[1]);
            }
          }
        }
      }
 
      // En timer som uppdaterar med jämna mellanrum
      Timer {
        interval: 5000 // Uppdatera var 5:e sekund
        running: true
        repeat: true
        onTriggered: batteryInfo.running = true
      }

      Component.onCompleted: {
        mainContainer.visible = true
      }

      ColumnLayout {
        anchors.centerIn: parent 
        spacing: 4

      Text {
        text: Math.round(mainContainer.batteryLevel * 100) + "%"
        color: mainContainer.level < 0.2 ? "#F57F82" : "black"
        font.family: "Work Sans"
        font.pixelSize: mainContainer.width * 0.2 
        //font.bold: true
        font.weight: Font.ExtraBold
        font.letterSpacing: -2 
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter 

        OpacityAnimator on opacity {
          from: 0; to: 1; duration: 150 
          running: true
        }
      }

      Rectangle {
        id: base
        width: mainContainer.width * 0.8  
        height: 20 
        color: "transparent"
        radius: 12
        opacity: 0.5
        border.color: "black"
        border.width: 2 
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Rectangle {
        id: filler
        height: 20
        width: 0 
        readonly property real targetW: (mainContainer.width * 0.8) * mainContainer.batteryLevel
        //color: "#CAE0A7" //ljusare
        color: "#A9BE88"
        radius: 12
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        //Layout.alignment: base.AlignVCenter


        Behavior on width {
          NumberAnimation {
            duration: 800 
            easing.type: Easing.OutCubic
          }
        }

        Timer {
          interval: 50 
          running: true 
          repeat: true 
          onTriggered: filler.width = filler.targetW
        }
        }

      }
      
      //Rectangle filler här ute tidigare
      
      }

      Text {
        text: "Battery: " + (mainContainer.isCharging ? "Charging" : "Discharging") 
        color: "black"
        font.pixelSize: 15
        font.family: "DepartureMono Nerd Font Mono"
        anchors.top: parent.top
        anchors.right: parent.right 
        anchors.topMargin: 10
        anchors.rightMargin: 10

        OpacityAnimator on opacity {
          from: 0; to: 1; duration: 150 
          running: true
        }
      }

      Text {
        text: "[o] options [esc] quit"
        color: "black"
        font.pixelSize: 15
        font.family: "DepartureMono Nerd Font Mono"
        anchors.bottom: parent.bottom
        anchors.left: parent.left 
        anchors.bottomMargin: 10
        anchors.leftMargin: 10

        OpacityAnimator on opacity {
          from: 0; to: 1; duration: 150 
          running: true
        }
      } 
    }
  }
}
