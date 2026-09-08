import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell

Item {
  width: 90
  height: 35

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
    width: 90
    height: 35
    radius: 10
    //color: "#191d1f"
    color: "#1E2528"
    border.color: "pink"
    border.width: 0

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

}
