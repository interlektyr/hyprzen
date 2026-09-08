import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts

//WCIdicator for zenshell 2.0

Scope {
  id: root

  function triggerShow() {
      hud.visible = true;
      if (showAnimation.running) showAnimation.stop();
      content.opacity = 1.0;
      hideTimer.restart();
  }
 
  PanelWindow {
    id: hud
    implicitWidth: 400    
    implicitHeight: 80
    color: "transparent"
    anchors.bottom: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "wc-indicator"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None 
    WlrLayershell.exclusiveZone: -1
    visible: content.opacity > 0
     
    Rectangle {
      id: content
      anchors.fill: parent 
      color: "transparent"
      opacity: 0

      NumberAnimation on opacity {
        id: showAnimation
        from: 0; to: 1; duration: 150
      } 

      Timer {
        id: hideTimer
        interval: 1000
        onTriggered: content.opacity = 0
      }

      Row {
        anchors.centerIn: parent
        spacing: 15

        Repeater {
          model: 10
          delegate: Rectangle {
            id: dot
            readonly property bool isActive: (index + 1) === ZenServices.activeWorkspace
            width: isActive ? 30 : 15
            height: width
            radius: width / 2
            color: isActive ? ZenServices.accentColor : "#555555"

            Behavior on width {

              SpringAnimation {
                spring: 3
                damping: 0.4
                mass: 1.0
                epsilon: 0.25 
              }
            } 

            Behavior on color {
              ColorAnimation { duration: 200 }
            }
          }
        }
      }
    }
  }
}
