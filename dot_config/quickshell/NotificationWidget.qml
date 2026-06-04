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
    implicitWidth: 350    
    implicitHeight: 400
    color: "transparent"
    anchors.top: true
    margins.top: 30
    anchors.right: true
    margins.right: 30

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notificationWidget_hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    //WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
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
          height: noteDelegate.isSelected ? contentColumn.implicitHeight + 20 : 50
          color: noteDelegate.isSelected ? "#F8F9E8" : "#f1f1f0"
          //visible: noteDelegate.isSelected
          //opacity: noteDelegate.isSelected ? 1 : 0.7
          radius: 12

          readonly property bool isSelected: ListView.isCurrentItem
 
          Column {
            id: contentColumn
            anchors.centerIn: parent
            width: parent.width - 20
            anchors.leftMargin: 2
            spacing: 2

            Text {
              width: parent.width
              text: modelData.summary
              color: "black"
              font.pixelSize: 20
              font.family: "Work Sans"
              font.weight: Font.Bold
              font.capitalization: Font.AllLowercase
              verticalAlignment: Text.AlignVCenter
              wrapMode: noteDelegate.isSelected ? Text.Wrap : Text.NoWrap
              elide: noteDelegate.isSelected ? Text.ElideNone : Text.ElideRight
              //visible: noteDelegate.isSelected Text.NoWrap 
            }

            Text {
              width: parent.width
              text: modelData.body
              color: "black"
              font.pixelSize: 14
              font.family: "DepartureMono Nerd Font Mono"
              verticalAlignment: Text.AlignVCenter
              wrapMode: noteDelegate.isSelected ? Text.Wrap : Text.NoWrap
              elide: noteDelegate.isSelected ? Text.ElideNone : Text.ElideRight
              //visible: noteDelegate.isSelected
            }
          } 
        }
      }

      
    } //Rectangle 
  } //PanelWIndow
}
