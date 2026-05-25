import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts

Scope {
  id: root

  property int currentWs: 1
  property color accentColor: "#ffffff"

  //onAccentColorChanged: console.log("Färg: " + accentColor)
  //onCurrentWsChanged: console.log("WS: " + currentWs)

  function triggerShow() {
    //showAnimation.restart();
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

      //Behavior on opacity {
      // NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
      //}

      Row {
        anchors.centerIn: parent
        spacing: 15

        Repeater {
          model: 10
          delegate: Rectangle {
            id: dot
            readonly property bool isActive: (index + 1) === root.currentWs
            //width: isActive ? 38 : 16
            width: isActive ? 30 : 15
            height: width
            radius: width / 2
            color: isActive ? root.accentColor : "#555555"
            //spacing: hud.opacity > 0 ? 20 : 10

            //Behavior on spacing {
            //  NumberAnimation { duration: 400; easing.type: Easin.OutBack }
            //}

            Behavior on width {
              //NumberAnimation { duration: 200; easing.type: Easing.OutBack }
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
