import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Quickshell.Io

//CLOCK V2

Scope {
  id: widgetRoot
  
  signal closeCRequested()

  PanelWindow {
    id: testWidget
    implicitWidth: Screen.width 
    implicitHeight: Screen.height
    color: "transparent" 

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "clock-hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1

    TapHandler {
      onTapped:
      widgetRoot.closeCRequested()
    }

    Rectangle {
      id: mainContainer 
      width: 300 
      height: 150
      color: "transparent"
      //anchors.centerIn: parent - ifall du vill ha den mitt på skärmen
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: 10
      focus: true
      radius: 12
      transformOrigin: Item.Top
      opacity: visible ? 1 : 0
      scale: visible ? 1 : 0
      visible: false 

      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      Keys.onEscapePressed: widgetRoot.closeCRequested()

      Component.onCompleted: {
        mainContainer.visible = true 
      }

      Text {
        id: clock
        text: Qt.formatDateTime(new Date(), "HH:mm")
        color: "#F5D098"
        font.family: "ttyclock"
        font.pixelSize: parent.width * 0.3
        anchors.centerIn: parent

        Timer {
          interval: 1000
          running: true
          repeat: true
          onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
      }
    }
  }
}

