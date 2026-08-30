import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts
import QtQml.Models
import Quickshell.Services.Notifications

//Item {
  //id: root
  //required property Notification modelData
  //readonly property bool isSelected: ListView.isCurrentItem
  
Rectangle {
          id: noteDelegate
          width: noteList.width

          required property Notification modelData
          readonly property bool isSelected: ListView.isCurrentItem
          //required property var serverRef

          //height: noteDelegate.isSelected || root.passiveWidget ? contentColumn.implicitHeight + 20 : 50
          //height: root.isSelected ? (contentColumn.implicitHeight + 20) : 50
          implicitHeight: isSelected ? (contentColumn.implicitHeight + 20) : 50
          //implicitHeight: contentColumn.implicitHeight + 20
          height: implicitHeight
          //color: "#f1f1f0"
          //color: modelData.urgency == 2 ? "pink" : isSelected && !root.passiveWidget ? "#F8F9E8" : "#f1f1f0"
          color: modelData.urgency == 2 ? "pink" : "#1E2528"
          //visible: root.passiveWidget && !newnote ? false : true   
          //opacity: noteDelegate.isSelected ? 1 : 0.7
          radius: 12
          opacity: visible ? 1 : 0
          scale: visible ? 1 : 0
          visible: false
          border.width: isSelected && !root.passiveWidget ? 2 : 0
          //border.width: isSelected ? 2 : 0
          border.color: modelData.urgency == 2 ? "#ff748c" : "pink"
          clip: true
          focus: isSelected

          Behavior on opacity { NumberAnimation { duration: 200 } }
          Behavior on scale { NumberAnimation { duration: 600; easing.type: Easing.OutBounce; easing.amplitude: 0.2 } }

          Component.onCompleted: {
            noteDelegate.visible = true;
            dismissTimer.running = true;
          }

          //readonly property bool isSelected: ListView.isCurrentItem

          Keys.onEscapePressed: { 
            //root.closeNoteWidgetRequested();
            root.passiveWidget = true
          }

          Keys.onPressed: (event) => {
            let actionIndex = -1 
            if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
              actionIndex = event.key - Qt.Key_1;
            }
            else if (event.key === Qt.Key_0) {
              actionIndex = 9;
            }
            if (actionIndex !== -1 && actionIndex < modelData.actions.length) {
              modelData.actions[actionIndex].invoke();
              event.accepted = true;
            }
            if ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
              console.log("Tryckt");
              let listModel = ListView.view.model
              if (listModel) {
                let allNotifs = Array.from(listModel)
                console.log(allNotifs.length)
                for (let i = 0; i < allNotifs.length; i++) {
                  if (allNotifs[i]) {
                    allNotifs[i].dismiss()
                  }
                }
              }
              //let allNotifs = Array.from(serverRef.trackedNotifications)
              //console.log(allNotifs.length);
              //for (let i = 0; i < allNotifs.length; i++) {
              //  if (allNotifs[i]) {
              //    allNotifs[i].dismiss()
              //  }
              //}
              event.accepted = true
              //event.accepted = true;
              //NotificationList.history.clear();
              //NotificationList.now.clear();
              //root.closeNoteWidgetRequested();
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              //event.accepted = true;
              //NotificationList.history.remove(noteList.currentIndex, 1); 
              //if (modelData.count === 1) {
              //  root.passiveWidget = true;
              //  modelData.dismiss();
              //  event.accepted = true;
              //} else {
              modelData.dismiss();
              event.accepted = true;
              //}
              //if (NotificationList.history.count === 0) {
              //  root.closeNoteWidgetRequested();
              //}
            } else if (event.key === Qt.Key_D) {
              if (doNotDisturbSet == false) {
                Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "toggledonotdisturbon"]);
              } else {
                Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "toggledonotdisturboff"]);
              }
              doNotDisturb();
            }
            //let item = NotificationList.history.get(noteList.currentIndex)
            //if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
            //  let targetIndex = event.key;
            //  modelData.actions[targetIndex].invoke();
              //let targetIndex = event.key;
              //if (item.rawN && targetIndex < item.rawN.actions.length) {
              //  let targetAction = item.rawN.actions[targetIndex];
              //  targetAction.invoke();
            //    event.accepted = true;
              //}
            //}
          }

          Text {
            //Använd detta för annan info, t.ex appname eller urgency
            //Problem, om summary är för långt kommer den att överlappa denna, alternativ
            //är att sätta width på summary som parent.width - (minus) ett värde som ungefär motsvarar
            //denna och sätta att dden alltid ska ha elide 
            text: modelData.urgency == 2 ? "!!!" : "!" 
            //text: "!"
            color: modelData.urgency == 2 ? "black" : "white"
            font.pixelSize: 14
            font.family: "DepartureMono Nerd Font Mono"
            anchors.top: parent.top
            anchors.right: parent.right 
            anchors.topMargin: 10
            anchors.rightMargin: 10
            //visible: noteDelegate.isSelected || root.passiveWidget ? true : false
            visible: isSelected ? true : false
          } 
 
          Column {
            id: contentColumn
            anchors.centerIn: parent
            width: parent.width - 20
            anchors.leftMargin: 2
            spacing: 2 

            Text {
              width: parent.width
              //text: NotificationList.history.count === 0 ? modelData.summary : summary
              text: modelData ? modelData.summary : ""
              color: modelData.urgency == 2 ? "black" : "white"
              font.pixelSize: 20
              font.family: "Work Sans"
              font.weight: Font.Bold
              font.capitalization: Font.AllLowercase
              verticalAlignment: Text.AlignVCenter
              //wrapMode: noteDelegate.isSelected || root.passiveWidget ? Text.Wrap : Text.NoWrap
              //elide: noteDelegate.isSelected || root.passiveWidget ? Text.ElideNone : Text.ElideRight
              wrapMode: isSelected ? Text.Wrap : Text.NoWrap
              elide: isSelected ? Text.ElideNone : Text.ElideRight
              //wrapMode: Text.Wrap
              //elide: Text.ElideNone

              //visible: noteDelegate.isSelected Text.NoWrap 
            }

            Text {
              width: parent.width
              //text: NotificationList.history.count === 0 ? modelData.body : body
              text: modelData ? modelData.body : ""
              //text: modelData.body
              color: modelData.urgency == 2 ? "black" : "white"
              font.pixelSize: 14
              font.family: "DepartureMono Nerd Font Mono"
              verticalAlignment: Text.AlignVCenter
              //wrapMode: noteDelegate.isSelected || root.passiveWidget ? Text.Wrap : Text.NoWrap
              //elide: noteDelegate.isSelected || root.passiveWidget ? Text.ElideNone : Text.ElideRight
              wrapMode: isSelected ? Text.Wrap : Text.NoWrap
              elide: isSelected ? Text.ElideNone : Text.ElideRight
              //wrapMode: Text.Wrap
              //elide: Text.ElideNone
              //visible: noteDelegate.isSelected
            }

            Column {
              id: actionColumn
              width: parent.width
              spacing: 2
              visible: modelData.actions.length > 0 && !root.passiveWidget && isSelected ? true : false
            //  Rectangle { width: parent.width; height: 1; color: "black" }

            //  property var currentItem: {

            //    if (root.passiveWidget) {
            //      return NotificationList.now.get(ListView.currentIndex); 
            //    } else {
            //      return NotificationList.history.get(ListView.currentIndex); 
            //    }
            //  }

            //  visible: currentItem && currentItem.actionTextStr !== ""

                Repeater {
                  model: modelData.actions

                  delegate: Text {
                    required property int index
                    required property var modelData
                    color: modelData.urgency == 2 ? "black" : "white"
                    font.pixelSize: 14
                    font.family: "DepartureMono Nerd Font Mono"
            //      text: modelData 
                    text: "[ " + (index + 1) + " ] " + modelData.text
                  //text: "test"
            //      color: "black"
            //      font.pixelSize: 14 
                  }
                }
            }

            Text {
              //text: "actions"
              text: "actions available"  
              //text: !root.passiveWidget ? "<br>" + actionTextStr.split(",") : "<br> Actons available"
              color: modelData.urgency == 2 ? "black" : "white"
              font.pixelSize: 14
              font.family: "DepartureMono Nerd Font Mono"
              verticalAlignment: Text.AlignVCenter
              //visible: noteDelegate.isSelected || root.passiveWidget ? true : false
              //visible: isSelected ? true : false
              visible: modelData.actions.length > 0 && root.passiveWidget ? true : false
            }
          } //Column one
  

  Timer {
    id: dismissTimer
    interval: 15000
    running: false
    onTriggered: {
      if (modelData.urgency !== 2) {  
        modelData.dismiss(); 
      }
    }
  }
}

