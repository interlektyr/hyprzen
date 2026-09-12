import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts
import QtQml.Models
import Quickshell.Services.Notifications

//notificationWidget for zenshell 2.0

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
      if ((n.urgency === 0 && ZenServices.lowTime === 0) || (n.urgency === 1 && ZenServices.normalTime === 0) || (n.urgency === 2 && ZenServices.criticalTime === 0)) {
        n.dismiss();
      } else {
        n.tracked = true;
        hud.visible = true;
        ZenServices.passiveNoteWidget = true;
      }
    }
  }

  GlobalShortcut {
    name: "clock_hud"
    onPressed: {
      if (ZenServices.showClock === true) {
        ZenServices.showClock = false;
      } else {
        ZenServices.showClock = true;
      }
    }
  }

  GlobalShortcut {
    name: "notificationWidget_hud"
    onPressed: {
      if (ZenServices.passiveNoteWidget === true) {
        ZenServices.toggleDnD = "no";
        ZenServices.passiveNoteWidget = false;
      } else {
        ZenServices.passiveNoteWidget = true;
      }
    }
  }

 
  PanelWindow {
    id: hud
    implicitWidth: 360    
    implicitHeight: Screen.height - 35
    color: "transparent"
    anchors.top: true
    margins.top: 5
    anchors.right: true
    margins.right: 6
    mask: Region { item: rect }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notificationWidget_hud"
    WlrLayershell.keyboardFocus: ZenServices.passiveNoteWidget || noteList.count === 0 ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
    WlrLayershell.exclusiveZone: -1

    TapHandler {
      onTapped:
      ZenServices.passiveNoteWidget = true
    }

    Column {
      id: widgetCol
      anchors.fill: parent 
      spacing: 5

      Row {
        id: topRow
        width: hud.width
        height: 35
        layoutDirection: Qt.RightToLeft
        visible: true
        spacing: 5

        ClockWidgetComponent {
          visible: ZenServices.showClock
        }

        Rectangle {
          id: dndcircleContainer
          height: 35
          width: height
          color: "transparent"
          visible: {
            let v = false;
            if (ZenServices.toggleDnD === "yes") {
              v = true;
            }
            return v;
          }

          Rectangle {
            id: dndCircle
            anchors.centerIn: parent 
            height: 25
            width: height
            radius: width / 2
            color: "pink"
            visible: dndcircleContainer.visible === true && noteList.count > 0 ? true : false 
          }
        }
      }
  
    Rectangle {
      id: content
      width: hud.width
      height: hud.height
      color: "transparent"
      opacity: 1
      visible: {
        let v = true;
        if (ZenServices.toggleDnD === "yes" || ZenServices.toggleDnD === "total") {
          v = false;
        }
        return v
      }
 
      ListView {
        id: noteList
        anchors.fill: parent 
        model: notifyService.trackedNotifications 
        clip: true 
        focus: true
        spacing: 6
        
        Timer {
          id: animHandler
          interval: 400
          running: false
          onTriggered: {
            noteList.currentIndex = noteList.count - 1
          }
        }
        
        onCountChanged: {
          noteList.currentIndex = noteList.count - 1
        }

        add: Transition {
          NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 400 }
          NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 300 }
        }

        displaced: Transition {
         NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutBounce }
        }

        delegate: NoteCard {}

      }

      
    } //Rectangle 
  } // Column
  } //PanelWIndow
}
