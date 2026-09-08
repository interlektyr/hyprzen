import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Quickshell.Io

//Appcommander for zenshell 2.0

Scope {
  id: widgetRoot  

  property var allApps: []

  Component.onCompleted: {
    allApps = DesktopEntries.applications.values.slice().sort((a, b) => a.name.localeCompare(b.name, Qt.locale().name));
  }

  Connections {
    target: DesktopEntries.applications
      function onValuesChanged() {
          allApps = DesktopEntries.applications.values.slice().sort((a, b) => a.name.localeCompare(b.name, Qt.locale().name));
    }
  }

  function fuzzyMatch(needle, haystack) {
    return haystack.toLowerCase().includes(needle.toLowerCase());
  }

  function cleanExecString(execStr) {
    if (!execStr) return ""; 
    let cleaned = execStr.replace(/\s%[a-zA-Z]/g, "").trim();
    cleaned = cleaned.replace(/['"]/g, "");
    return cleaned;
  }

  PanelWindow {
    id: testWidget
    implicitWidth: Screen.width 
    implicitHeight: Screen.height
    color: "transparent" 

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "appcommander_hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1

    TapHandler {
      onTapped:
      ZenServices.toggleAppCommander = false
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

      Keys.onEscapePressed: ZenServices.toggleAppCommander = false

      Component.onCompleted: {
        inputRec.visible = true
      }

      Text {
        id: titleAC
        text: "appcommander"
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
          Layout.fillWidth: true
          Layout.preferredHeight: 30
          Layout.margins: 20
          Layout.topMargin: titleAC.height + 5
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
                var rawExec = listView.model[listView.currentIndex].execString;
                var cleanCmd = cleanExecString(rawExec);
                var termRun = listView.model[listView.currentIndex].runInTerminal;
                if (listView.model[listView.currentIndex].runInTerminal) {
                  let argTwo = ""
                  if (ZenServices.termLaunchArg == "kitty") {
                    argTwo = "-e"
                  }
                  //TEST TA BORT DENNA KÖR NEDAN Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", widgetRoot.terminalOpt, cleanCmd]);
                  Quickshell.execDetached([ZenServices.termLaunchArg, argTwo, cleanCmd]);
                } else {
                  Quickshell.execDetached(["sh", "-c", cleanCmd]); 
                }
               ZenServices.toggleAppCommander = false;
              } 
            }        
        }

        Rectangle {
          id: listRec
          Layout.fillWidth: true
          Layout.preferredHeight: mainRow.height * 0.60
          color: "transparent"
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
                return allApps;
              }

              let filtered = [];

              for (let i = 0; i < allApps.length; i++) {
                const app = allApps[i];
                if (fuzzyMatch(query, app.name + " " + (app.comment || "") + " " + (app.execString || ""))) {
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
                  text: ">"
                  color: "#f8f9e8"
                  font.family: "DepartureMono Nerd Font Mono"
                  visible: itemDelegate.isSelected
                  anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                  text: modelData.name
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
  } //PanelWindow
} // Scope
              
