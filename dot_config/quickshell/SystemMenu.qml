import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Quickshell.Io

Scope {
  id: widgetRoot
  
  signal closeSMRequested()

  property string terminalOpt: "kitty"

  QtObject {
    id: powerOpt 

    property var powerEntries: [
      { title: "mirrors", desc: "run rate-mirrors" },         
      { title: "update", desc: "run arch-update" },
      { title: "clean", desc: "launch moonbit" },
      { title: "monitor", desc: "launch bottom" }
    ] 
  }
 
  PanelWindow {
    id: testWidget
    implicitWidth: Screen.width 
    implicitHeight: Screen.height
    color: "transparent" 

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "zensys_hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1

    TapHandler {
      onTapped:
      widgetRoot.closeSMRequested()
    }

    Rectangle {
      id: testRec 
      width: 520 
      height: 260
      color: "#F8F9E8"
      anchors.centerIn: parent //- ifall du vill ha den mitt på skärmen
      //anchors.horizontalCenter: parent.horizontalCenter
      //anchors.top: parent.top
      //anchors.topMargin: 10
      //focus: true
      radius: 12
      transformOrigin: Item.Top
      opacity: visible ? 1 : 0
      scale: visible ? 1 : 0
      visible: false 

      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                  widgetRoot.closeSMRequested();
                  console.log("Registrerad");
                  //event.accepted = true;
                }
                else if (event.key === Qt.Key_Down) {
                  //event.accepted = true;
                  if (listView.count > 0) {
                    listView.currentIndex = (listView.currentIndex + 1) % listView.count;       
                  }
                }
                else if (event.key === Qt.Key_Up) {
                  //event.accepted = true; 
                  if (listView.count > 0) {
                    listView.currentIndex = (listView.currentIndex - 1 + listView.count) % listView.count
                  }
                }
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                  //event.accepted = true;
                  if (listView.currentIndex === 0) {
                    //event.accepted = true;
                    Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", widgetRoot.terminalOpt, "zen_mirrors"]);
                    widgetRoot.closeSMRequested();
                  } else if (listView.currentIndex === 1) {
                    //event.accepted = true;
                    Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", widgetRoot.terminalOpt, "cachy-update"]);
                    widgetRoot.closeSMRequested();
                  } else if (listView.currentIndex === 2) {
                    //event.accepted = true;
                    Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", widgetRoot.terminalOpt, "moonbit"]);
                    widgetRoot.closeSMRequested();
                  } else if (listView.currentIndex === 3) {
                    //event.accepted = true;
                    Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", widgetRoot.terminalOpt, "btm"]);
                    widgetRoot.closeSMRequested();
                  } 
                }
      } 
 
      Timer {
        id: animTimer 
        interval: 300
        running: false 
        repeat: false 
        onTriggered: dateProc.running = true
      }

      Component.onCompleted: {
        testRec.visible = true
        //forceActiveFocus()
        //widgetRoot.windowFetcher.running = true
      }

      Text {
        text: "system"
        color: "#272E33"
        font.pixelSize: 50
        font.family: "Work Sans"
        font.weight: Font.Bold
        font.letterSpacing: -3  
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
        text: "[\uf062/\uf063] navigation [enter] " + powerOpt.powerEntries[listView.currentIndex].desc + " [esc] quit"
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
        spacing: 0

        property int recW: 5

        Rectangle {
          id: optionsRec
          Layout.preferredWidth: (mainRow.width / 2) - (mainRow.recW * 2) 
          Layout.preferredHeight: mainRow.height - (mainRow.recW * 2) - 50 
          Layout.margins: mainRow.recW + 5
          Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          color: "transparent"

          ListView {
            id: listView
            //anchors.fill: parent
            anchors.centerIn: parent
            //anchors.horizontalCenter: optionsRec.horizontalCenter
            //anchors.verticalCenter: optionsRec.verticalCenter
            width: parent.width
            height: contentHeight
            anchors.margins: 5 
            model: powerOpt.powerEntries
            clip: true
            focus: true 
            currentIndex: 0 
            spacing: 5
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
                  width: 20
                  text: ">"
                  color: "pink"
                  font.pixelSize: 26
                  font.family: "DepartureMono Nerd Font Mono"
                  visible: itemDelegate.isSelected
                  //Layout.preferredWidth: 20
                  anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                  text: modelData.title
                  color: isSelected ? "pink" : "black"
                  font.pixelSize: 26 
                  font.family: "DepartureMono Nerd Font Mono"
                  verticalAlignment: Text.AlignVCenter
                  horizontalAlignment: Text.AlignHCenter
                  height: parent.height
                }
              }
            } 

            //Component.onCompleted: forceActiveFocus()
            //onActiveFocusChanged: console.log("Focus: ", activeFocus)

          }
        }

        Rectangle {
          id: imageRec
          Layout.preferredWidth: mainRow.width / 2
          Layout.preferredHeight: mainRow.height
          Layout.margins: 0
          Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          color: "transparent"
        }

      }

      //ColorAnimation on color { from: "black"; to: "blue"; duration: 2000 }

    }
  }
}
