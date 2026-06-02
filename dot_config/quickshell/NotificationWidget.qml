import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts

Scope {
  id: root

  //function triggerShow() {
    //showAnimation.restart();
  //    hud.visible = true;
  //    if (showAnimation.running) showAnimation.stop();
  //    content.opacity = 1.0;
  //    hideTimer.restart();
  //}

  property var noteModel: [
    { summary: "test", body: "This is a test notification dummy" },
    { summary: "another test", body: "This is an additional notification dummy" },
    { summary: "another test", body: "This is an additional notification dummy" },
    { summary: "another test", body: "This is an additional notification dummy with a very long message" }
  ]
 
  PanelWindow {
    id: hud
    implicitWidth: 300    
    implicitHeight: 300
    color: "transparent"
    anchors.top: true
    margins.top: 30
    anchors.right: true
    margins.right: 30

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notificationWidget_hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None 
    WlrLayershell.exclusiveZone: -1
    visible: content.opacity > 0
     
    Rectangle {
      id: content
      anchors.fill: parent 
      color: "transparent"
      opacity: 1

      ListView {
        id: noteList
        anchors.fill: parent 
        model: noteModel 
        clip: true 
        focus: true
        spacing: 5

        delegate: Rectangle {
          id: noteDelegate
          width: noteList.width
          height: 50
          color: "red"

          readonly property bool isSelected: ListView.isCurrentItem
 
          Column {
            anchors.centerIn: parent
            width: parent.width - 20
            anchors.leftMargin: 2
            spacing: 2

            Text {
              text: modelData.summary
              color: "white"
              font.pixelSize: 11
              font.family: "DepartureMono Nerd Font Mono"
              verticalAlignment: Text.AlignVCenter
              //height: parent.height
            }

            Text {
              text: modelData.body
              color: "white"
              font.pixelSize: 11
              font.family: "DepartureMono Nerd Font Mono"
              verticalAlignment: Text.AlignVCenter
              //height: parent.height
            }
          } 
        }
      }

      
    } //Rectangle 
  } //PanelWIndow
}
