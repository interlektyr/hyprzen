import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Quickshell.Io

//Sasher final V2

Scope {
  id: widgetRoot

  property var specialWindow: []

  Process {
  id: windowFetcher
  running: true
  command: ["hyprctl", "clients", "-j"]
  stdout: StdioCollector {
    onStreamFinished: {
      try {
        let allWindows = JSON.parse(text);

        let filtered = allWindows
          .filter(w => w.workspace.id === -98)
          .map(w => ({
            "class": w.class,
            "title": w.title,
            "address": w.address
          }))
        specialWindow = filtered;
        console.log("Hittade " + specialWindow.length + " fönster.");
      } catch (e) {
        console.log("Kunde inte parsa JSON: " + e);
      }
    }
  }
  } 

  function fuzzyMatch(needle, haystack) {
    return haystack.toLowerCase().includes(needle.toLowerCase());
  }
  
  signal closeStasherRequested()

  PanelWindow {
    id: testWidget
    implicitWidth: Screen.width 
    implicitHeight: Screen.height
    color: "transparent" 

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "stasher_hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1

    TapHandler {
      onTapped:
      widgetRoot.closeStasherRequested()
    }

    Rectangle {
      id: inputRec
      clip: true
      antialiasing: true
      width: 1000
      height: 500 
      color: "#1E2528"
      anchors.centerIn: parent
      focus: true 
      radius: 12
      opacity: visible ? 1 : 0
      scale: visible ? 1 : 0
      visible: false
      border.color: "pink"
      border.width: 2 

      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      Keys.onEscapePressed: closeStasherRequested()

      Component.onCompleted: {
        inputRec.visible = true
      }

      Text {
        id: titleStasher
        text: "stasher"
        color: "white"
        font.pixelSize: 70
        font.family: "Work Sans"
        font.weight: Font.ExtraBold
        font.letterSpacing: -5 
        anchors.top: parent.top
        anchors.right: parent.right 
        anchors.topMargin: -5 
        anchors.rightMargin: 12 + inputRec.border.width

        OpacityAnimator on opacity {
          from: 0; to: 1; duration: 150 
          running: true
        }
      }

      ColumnLayout {
        id: mainRow
        anchors.fill: parent
        anchors.bottomMargin: 10
        spacing: 2
        clip: true

        TextInput {
          id: searchField
          //anchors.fill: parent
          //anchors.margins: 10
          //anchors.leftMargin: 20
          //anchors.rightMargin: 20
          //anchors.topMargin: 30
          Layout.fillWidth: true
          //Layout.fillHeight: true
          Layout.preferredHeight: 30
          Layout.margins: 20
          Layout.topMargin: titleStasher.height + 5
          focus: true
          color: "white"
          font.pixelSize: 30
          font.family: "DepartureMono Nerd Font"
          cursorDelegate: Rectangle {
          width: 10
          color: "#F5D098"

          SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { from: 1; to: 0; duration: 500 }
            NumberAnimation { from: 0; to: 1; duration: 500 }
          }
          }
         
          Component.onCompleted: forceActiveFocus()

          onTextChanged: { 
            listView.currentIndex = 0;
          }

          Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Down) {
              event.accepted = true;
              if (listView.count > 0) {
              listView.currentIndex = (listView.currentIndex + 1) % listView.count;
              }
            }
            else if (event.key === Qt.Key_Up) {
              event.accepted = true;
              if (listView.count > 0) {
                listView.currentIndex = (listView.currentIndex - 1 + listView.count) % listView.count
              }
            }
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              event.accepted = true;
              var getBackId = listView.model[listView.currentIndex].address;
              var commandType = "stasher"
              Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", commandType, getBackId]);
              widgetRoot.closeStasherRequested()
            } 
          }
        }

        Rectangle {
          id: listRec
          Layout.fillWidth: true            
          //Layout.fillHeight: true
          Layout.preferredHeight: mainRow.height * 0.60
          color: "transparent"
          //Layout.bottomMargin: 50
          //Layout.margins: 10
          radius: 12
          clip: true

          ListView {
            id: listView  
            anchors.fill: parent
            anchors.margins: 5
            anchors.leftMargin: 20
            anchors.bottomMargin: 5
            model: {
              let query = searchField.text.trim();

              if (query === "") {
                return specialWindow;
              }

              let filtered = [];

              for (let i = 0; i < specialWindow.length; i++) {
                const app = specialWindow[i];
                if (fuzzyMatch(query, app.title + " " + (app.class || "") + " " + (app.address || ""))) {
                  filtered.push(app);
                }
              }

              return filtered;
            }
          
            clip: true 
            currentIndex: 0
            spacing: 0

            highlightMoveDuration: 200
            highlightFollowsCurrentItem: true

            delegate: Item {
              id: itemDelegate
              width: listView.width
              height: 20

              readonly property bool isSelected: ListView.isCurrentItem

              Row {
                anchors.fill: parent
                anchors.leftMargin: 0
                spacing: 1

                Text {
                  width: 15
                  //text: "\uf061"
                  text: ">"
                  color: "#f8f9e8"
                  font.family: "DepartureMono Nerd Font Mono"
                  visible: itemDelegate.isSelected
                  //Layout.preferredWidth: 20
                  anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                  //comment innebär lång beskrivning,
                  //text: modelData.name + " (" + modelData.keywords + ") "
                  text: modelData.class + modelData.title
                  color: isSelected ? "pink" : "#f8f9e8"
                  font.pixelSize: 16
                  font.family: "DepartureMono Nerd Font Mono"
                  verticalAlignment: Text.AlignVCenter
                  height: parent.height
                }
              }
            }
          } // ListView?
        } //TextInput + Rectangle
      } //CColumn
    } //Rectangle
  } // PanelWindow
}
