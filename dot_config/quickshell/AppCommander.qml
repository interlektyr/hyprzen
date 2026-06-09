import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Quickshell.Io

//Appcommander final

Scope {
  id: widgetRoot

  property string terminalOpt: "kitty"

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
  
  signal closeACRequested()

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
      widgetRoot.closeACRequested()
    }

    Rectangle {
      id: testRec 
      width: 1000 
      height: 500
      color: "#F8F9E8"
      anchors.centerIn: parent //- ifall du vill ha den mitt på skärmen
      //anchors.horizontalCenter: parent.horizontalCenter
      //anchors.top: parent.top
      //anchors.topMargin: 10
      focus: true
      radius: 12
      transformOrigin: Item.Top
      opacity: visible ? 1 : 0
      scale: visible ? 1 : 0
      visible: false 

      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      Keys.onEscapePressed: widgetRoot.closeACRequested()

      Component.onCompleted: {
        testRec.visible = true
      }

      //main heading
      Text {
        text: "appcommander"
        color: "#272E33"
        font.pixelSize: 70
        font.family: "Work Sans"
        font.weight: Font.ExtraBold
        font.letterSpacing: -5 
        anchors.top: parent.top
        anchors.right: parent.right 
        anchors.topMargin: -5 
        anchors.rightMargin: 10

        OpacityAnimator on opacity {
          from: 0; to: 1; duration: 150 
          running: true
        }
      }

      Text {
        text: "[\uf062/\uf063] navigation [enter] launch [esc] quit"
        color: "#1e2528"
        font.pixelSize: 15
        font.family: "DepartureMono Nerd Font Mono"
        anchors.bottom: parent.bottom
        anchors.left: parent.left 
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        font.letterSpacing: -1

        OpacityAnimator on opacity {
          from: 0; to: 1; duration: 150 
          running: true
        }
      }

      RowLayout {
        id: mainRow
        anchors.fill: parent
        spacing: 2 
        //anchors.margins: 10

        
        ColumnLayout {
          Layout.preferredWidth: parent.width / 2 
          Layout.fillHeight: true
          Layout.margins: 12 
          spacing: 5
          Layout.alignment: Qt.AlignHCenter
          //Layout.topMargin: 50

          //Item {
          Rectangle {
            id: inputRec
            //Layout.fillWidth: true
            Layout.preferredWidth: mainRow.width / 3
            Layout.preferredHeight: 30
            //Layout.fillHeight: true
            Layout.rightMargin: 5
            radius: 12
            color: "#272E33"
            clip: true
            antialiasing: true 

            TextInput {
              id: searchField
              anchors.fill: parent
              anchors.margins: 5
              anchors.leftMargin: 10
              anchors.rightMargin: 20
              //Layout.fillWidth: true
              //Layout.maximumWidth: 100
              //Layout.margins: 20
              focus: true
              color: "white" //gjort osynlig för att täckas av nedan
              font.pixelSize: 15
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
                console.log("Ner");
              }
              else if (event.key === Qt.Key_Up) {
                event.accepted = true;
                if (listView.count > 0) {
                  listView.currentIndex = (listView.currentIndex - 1 + listView.count) % listView.count
                }
                //console.log("Up");
              }
              else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true;
                //const exCom = listView.model[listView.currentIndex];
                //console.log(exCom.execString);
                var rawExec = listView.model[listView.currentIndex].execString;
                var cleanCmd = cleanExecString(rawExec);
                //var termRun = listView.model[listView.currentIndex].runInTerminal;
                console.log("Original:", rawExec);
                console.log("Städad:", cleanCmd);
                var termRun = listView.model[listView.currentIndex].runInTerminal;
                console.log(termRun)
                if (listView.model[listView.currentIndex].runInTerminal) {
               //Quickshell.execDetached(["sh", "-c", "kitty", "-e", cleanCmd]);
                  Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", widgetRoot.terminalOpt, cleanCmd]);
                } else {
                  Quickshell.execDetached(["sh", "-c", cleanCmd]); 
                }
               widgetRoot.closeACRequested();
              } 
            }
            }
          } // Rec 1 + searchField i Column 

          Rectangle {
            id: listRec
            Layout.fillWidth: true            
            //Layout.fillHeight: true
            Layout.preferredHeight: mainRow.height * 0.70
            color: "#272E33"
            //Layout.bottomMargin: 20
            radius: 12
            clip: true

            ListView {
              id: listView 
              //anchors.fillWidth: true 
              //anchors.fillHeight: true
              anchors.fill: parent
              anchors.margins: 5
              anchors.leftMargin: 10
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
          } // Rec 2 + listview in Column
        }// First Column

        //Item {
        //  Layout.fillWidth: true 
        //  Layout.fillHeight: true
        //}

        Rectangle {
          Layout.preferredWidth: parent.width / 2            
          Layout.fillHeight: true
          color: "transparent"
          radius: 12
        }

      } // First row
    }
 }
}
