import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts
import QtQml.Models

Scope {
  id: root

  Component.onDestruction: {
    NotificationList.now.clear();
  }

  //function triggerShow() {
    //showAnimation.restart();
  //    hud.visible = true;
  //    if (showAnimation.running) showAnimation.stop();
  //    content.opacity = 1.0;
  //    hideTimer.restart();
  //}

  signal closeNoteWidgetRequested()
  property bool passiveWidget: true

  property var noteModel: [
    { summary: "test", body: "This is a test notification dummy" },
    { summary: "another test", body: "This is an additional notification dummy" },
    { summary: "another test", body: "This is an additional notification dummy" },
    { summary: "another test", body: "This is an additional notification dummy with a very long message" }
  ] 
 
  PanelWindow {
    id: hud
    implicitWidth: 360    
    implicitHeight: 810
    color: "transparent"
    anchors.top: true
    margins.top: 30
    anchors.right: true
    margins.right: 30

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notificationWidget_hud"
    WlrLayershell.keyboardFocus: root.passiveWidget ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
    //WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: -1
    //visible: content.opacity > 0
  
    Rectangle {
      id: content
      anchors.fill: parent
      color: "transparent"
      opacity: 1 
 
      ListView {
        id: noteList
        anchors.fill: parent 
        model: {
          if (root.passiveWidget) {
            return NotificationList.now;
          } else {
            if (NotificationList.history.count === 0) {
              let emptyNote = [
                { summary: "no notifications", body: "There is no notifications to show. Either none has been send or all has been erased from history. Press [ESC] to exit" }
              ];
              return emptyNote;
            } else {
              return NotificationList.history;
            }
          }
        }  
        clip: true 
        focus: true
        spacing: 6
        //snapMode: ListView.SnapToItem
        //highlightRangeMode: ListView.ApplyRange
        onCountChanged: noteList.currentIndex = 0
 
        add: Transition {
          NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 400 }
          NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 300 }
        }

        displaced: Transition {
         NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutBounce }
        }

        delegate: Rectangle {
          id: noteDelegate
          width: noteList.width
          height: noteDelegate.isSelected || root.passiveWidget ? contentColumn.implicitHeight + 20 : 50
          color: urgency == 2 ? "pink" : noteDelegate.isSelected ? "#F8F9E8" : "#f1f1f0"
          //visible: root.passiveWidget && !newnote ? false : true   
          //opacity: noteDelegate.isSelected ? 1 : 0.7
          radius: 12
          opacity: visible ? 1 : 0
          scale: visible ? 1 : 0
          visible: false

          Behavior on opacity { NumberAnimation { duration: 200 } }
          Behavior on scale { NumberAnimation { duration: 600; easing.type: Easing.OutBounce; easing.amplitude: 0.2 } }

          Component.onCompleted: {
            noteDelegate.visible = true
          }

          readonly property bool isSelected: ListView.isCurrentItem

          Keys.onEscapePressed: { 
            root.closeNoteWidgetRequested();
          }

          Keys.onPressed: (event) => {
            if ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
              event.accepted = true;
              NotificationList.history.clear();
              root.closeNoteWidgetRequested();
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              //event.accepted = true;
              NotificationList.history.remove(noteList.currentIndex, 1);
              if (NotificationList.history.count === 0) {
                root.closeNoteWidgetRequested();
              }
            }           
          }

          Text {
            //Använd detta för annan info, t.ex appname eller urgency
            //Problem, om summary är för långt kommer den att överlappa denna, alternativ
            //är att sätta width på summary som parent.width - (minus) ett värde som ungefär motsvarar
            //denna och sätta att dden alltid ska ha elide 
            text: urgency == 2 ? "!!!" : "!" 
            color: "black"
            font.pixelSize: 14
            font.family: "DepartureMono Nerd Font Mono"
            anchors.top: parent.top
            anchors.right: parent.right 
            anchors.topMargin: 10
            anchors.rightMargin: 10
            visible: noteDelegate.isSelected || root.passiveWidget ? true : false 
          } 
 
          Column {
            id: contentColumn
            anchors.centerIn: parent
            width: parent.width - 20
            anchors.leftMargin: 2
            spacing: 2 

            Text {
              width: parent.width
              text: NotificationList.history.count === 0 ? modelData.summary : summary
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
              text: NotificationList.history.count === 0 ? modelData.body : body
              color: "black"
              font.pixelSize: 14
              font.family: "DepartureMono Nerd Font Mono"
              verticalAlignment: Text.AlignVCenter
              wrapMode: noteDelegate.isSelected ? Text.Wrap : Text.NoWrap
              elide: noteDelegate.isSelected ? Text.ElideNone : Text.ElideRight
              //visible: noteDelegate.isSelected
            }

            Text {
              text: !root.passiveWidget ? "<br>[\uf061] action" : "<br>action"
              color: "black"
              font.pixelSize: 14
              font.family: "DepartureMono Nerd Font Mono"
              verticalAlignment: Text.AlignVCenter
              visible: noteDelegate.isSelected || root.passiveWidget ? true : false
            } 
          } 
        } //delgate

        //Component.onCompleted: console.log(noteListT.body);


      }

      
    } //Rectangle 
  } //PanelWIndow
}
