import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects

PanelWindow {
  id: clockBase
  //anchors.bottom: true
  anchors.right: true
  anchors.top: true
  //margins.bottom: 5
  margins.top: 5 
  margins.right: 5 
  implicitHeight: 35
  implicitWidth: 90
  color: "transparent"

  Rectangle {
    id: clockHolder
    anchors.fill: parent
    radius: 10
    color: "#191d1f"
    //opacity: 0.7
    visible: false
 
    Text {
      id: clock
      anchors.centerIn: parent
      text: Qt.formatDateTime(new Date(), "HH:mm")
      color: "#F5D098"
      font.family: "Work Sans"
      font.weight: Font.ExtraBold
      font.letterSpacing: 0
      font.pixelSize: 22

      Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
      }
    }
  }
 
  MultiEffect {
    source: clockHolder
    anchors.fill: clockHolder
    shadowEnabled: false
    //autoPaddingEnabled: false
    //paddingRect: Qt.rect(20, 20, 40, 30)
    maskEnabled: false
    maskSource: clockHolder
  }

}
