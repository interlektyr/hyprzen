import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts
import QtQml.Models
import Quickshell.Services.Notifications

Scope {
  id: root

  NotificationServer {
      id: notifyService
      actionsSupported: true
      bodySupported: true
      bodyMarkupSupported: true
      persistenceSupported: true
      bodyHyperlinksSupported: true
  }

  Connections {
    target: notifyService
    function onNotification(n) {
      n.tracked = true;
      //NotificationList.add(n);
      hud.visible = true;
      passiveWidget = true;
    }
  }

  GlobalShortcut {
      name: "notificationWidget_hud"
      onPressed: {
      root.passiveWidget = false  
      }
  }

  Component.onDestruction: {
    NotificationList.now.clear();
  }

  signal closeNoteWidgetRequested()
  signal doNotDisturb()
  property bool passiveWidget: true
  property bool doNotDisturbSet: false

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
    margins.top: 45
    anchors.right: true
    margins.right: 6
    //anchors.left: true
    //margins.left: 5
    mask: Region { item: rect }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notificationWidget_hud"
    WlrLayershell.keyboardFocus: root.passiveWidget || noteList.count === 0 ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
    //WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: -1
    //visible: content.opacity > 0

    TapHandler {
      onTapped:
      //root.closeNoteWidgetRequested()
      root.passiveWidget = true
    } 
  
    Rectangle {
      id: content
      anchors.fill: parent
      color: "transparent"
      opacity: 1 
 
      ListView {
        id: noteList
        anchors.fill: parent 
        model: notifyService.trackedNotifications 
        clip: true 
        focus: true
        spacing: 6
        //snapMode: ListView.SnapToItem
        //highlightRangeMode: ListView.ApplyRange
        
        //readonly property bool isSelected: ListView.isCurrentItem
        
        Timer {
          id: animHandler
          interval: 400
          running: false
          onTriggered: {
            //noteList.currentIndex = 0
            //ListView.currentIndex = 0
            noteList.currentIndex = noteList.count - 1
          }
        }
        
        onCountChanged: {
          //animHandler.running = true;
          noteList.currentIndex = noteList.count - 1
          //noteList.currentIndex = 0
        }

        add: Transition {
          NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 400 }
          NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 300 }
        }

        displaced: Transition {
         NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutBounce }
        }

        delegate: NoteCard {
          //readonly property bool isSelected: ListView.isCurrentItem
          //notif: modelData
          //serverRef: notifyService 
        }

        //Component.onCompleted: console.log(noteListT.body);


      }

      
    } //Rectangle 
  } //PanelWIndow
}
