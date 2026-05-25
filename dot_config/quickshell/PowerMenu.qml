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
  
  signal closePowerMRequested()

  QtObject {
    id: powerOpt 

    property var powerEntries: [
      { title: "lock", desc: "session lock", cm: "" },         
      { title: "shutdown", desc: "shutdown", cm: "Shutdown the system?" },
      { title: "exit", desc: "exit hyprland", cm: "Exit Hyprland?" },
      { title: "reboot", desc: "reboot", cm: "Reboot the system?" },
      { title: "firmware", desc: "reboot into firmware", cm: "Reboot into firmware?" }
    ] 
  }

  QtObject {
    id: confirmOpt

    property var confirmEntries: [
      { title: "yes" },
      { title: "no" }
    ]
  }
 
  PanelWindow {
    id: testWidget
    implicitWidth: Screen.width 
    implicitHeight: Screen.height
    color: "transparent" 

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "power-hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1

    TapHandler {
      onTapped:
      widgetRoot.closePowerMRequested()
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
      focus: true
      radius: 12
      transformOrigin: Item.Top
      opacity: visible ? 1 : 0
      scale: visible ? 1 : 0
      visible: false 

      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      //Keys.onEscapePressed: widgetRoot.closePowerMRequested()

      Keys.onPressed: (event) => {
        //if (confirmRec.visible === false) {
        if (event.key === Qt.Key_Down) {
          if (confirmRec.visible === false) { 
          event.accepted = true;
          if (listView.count > 0) {
            listView.currentIndex = (listView.currentIndex + 1) % listView.count;       
          }
        }
        }
        else if (event.key === Qt.Key_Up) {
          if (confirmRec.visible === false) {
          event.accepted = true; 
          if (listView.count > 0) {
          listView.currentIndex = (listView.currentIndex - 1 + listView.count) % listView.count
          }
        }
        }
        else if (event.key === Qt.Key_Right) {
          if (confirmRec.visible === true) {
          event.accepted = true;
          if (confirmList.count > 0) {
            confirmList.currentIndex = (confirmList.currentIndex + 1) % confirmList.count;
          }
          }
        }
        else if (event.key === Qt.Key_Left) {
          if (confirmRec.visible === true) {
          event.accepted = true;
          if (confirmList.count > 0) { 
            confirmList.currentIndex = (confirmList.currentIndex - 1 + confirmList.count) % confirmList.count
          }
        }
        }
        else if (event.key === Qt.Key_Escape) {
          if (confirmRec.visible === false) {
            widgetRoot.closePowerMRequested();
            event.accepted = true;
          } else if (confirmRec.visible === true) {
              confirmRec.visible = false;
              confirmList.currentIndex = 0;
              event.accepted = true;
          }
        } 
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (listView.currentIndex === 0) {
              Quickshell.execDetached(["quickshell", "-p", Quickshell.env("HOME") + "/.config/quickshell/WIMLockScreen.qml"]);
              widgetRoot.closePowerMRequested();
              event.accepted = true;
            } else if (confirmRec.visible === false) {
                confirmList.currentIndex = 0;
                confirmRec.visible = true;
                event.accepted = true;
            } else if (confirmRec.visible === true && confirmList.currentIndex === 0) {
              if (listView.currentIndex === 1) {
                Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "shutdown"]);
              } else if (listView.currentIndex === 2) {
                Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "exit"]);
              } else if (listView.currentIndex === 3) {
                Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "reboot"]);
              } else if (listView.currentIndex === 4) {
                Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "firmware"]); 
              } 
            } else if (confirmRec.visible === true && confirmList.currentIndex === 1) {
              confirmRec.visible = false;
              confirmList.currentIndex = 0;
              event.accepted = true;
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
        //widgetRoot.windowFetcher.running = true
      }

      Text {
        text: "power"
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
      Rectangle {
        id: confirmRec
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -15
        width: 300
        height: 150
        radius: 12
        color: "pink"
        visible: false
        focus: false
        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0


          Behavior on opacity { NumberAnimation { duration: 200 } }
          Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

        Text {
          text: powerOpt.powerEntries[listView.currentIndex].cm 
          color: "black"
          font.pixelSize: 15
          font.family: "DepartureMono Nerd Font Mono"
          anchors.top: parent.top
          anchors.left: parent.left  
          anchors.topMargin: 5 
          anchors.leftMargin: 10
        }

        ListView {
          id: confirmList
          orientation: ListView.Horizontal
          anchors.centerIn: parent
          //anchors.fill: parent
          width: contentWidth
          //width: parent.width
          height: parent.height
          anchors.margins: 5 
          model: confirmOpt.confirmEntries
          clip: true 
          currentIndex: 0 
          spacing: 3
          highlightMoveDuration: 200
          highlightFollowsCurrentItem: true
          delegate: Item {
            id: itemDelegate 
            //width: confirmList.width
            width: 100
            height: confirmList.height

            readonly property bool isConSelected: ListView.isCurrentItem 

            Row {
              anchors.fill: parent 
              anchors.leftMargin: 0 
              spacing: 1

              Text {
                width: 30
                text: ">"
                color: "black"
                font.pixelSize: 26
                font.family: "DepartureMono Nerd Font Mono"
                opacity: itemDelegate.isConSelected
                  //Layout.preferredWidth: 20
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: modelData.title
                color: isConSelected ? "white" : "black"
                font.pixelSize: 26 
                font.family: "DepartureMono Nerd Font Mono"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                height: parent.height
              }
            }
          }    
        }
      }

      DropShadow {
        anchors.fill: confirmRec
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: confirmRec
        visible: confirmRec.visible
        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0


        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
      }
    }
  }
}
