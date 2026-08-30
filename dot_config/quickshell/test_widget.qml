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
  
  signal closeTestRequested()

  PanelWindow {
    id: testWidget
    implicitWidth: Screen.width 
    implicitHeight: Screen.height
    color: "transparent" 

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "test-hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1

    TapHandler {
      onTapped:
      widgetRoot.closeTestRequested()
    }

    Rectangle {
      id: volumeContainer 
      width: 150 
      height: width
      color: FontsAndColors.zenBackground
      anchors.centerIn: parent
      //anchors.horizontalCenter: parent.horizontalCenter
      //anchors.top: parent.top
      //anchors.topMargin: 10
      focus: true
      radius: width / 2
      transformOrigin: Item.Top
      opacity: visible ? 1 : 0
      scale: visible ? 1 : 0
      visible: false
      //border.width: 5
      //border.color: "white"

      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      Keys.onEscapePressed: widgetRoot.closeTestRequested()

      Component.onCompleted: {
        volumeContainer.visible = true
      }

      property real volLevel: 0
      property bool isMuted: false
      property real smoothedVol: 0

      onVolLevelChanged: smoothedVol = volLevel

      Behavior on smoothedVol {
        NumberAnimation { 
            duration: 500
            easing.type: Easing.OutCubic
          }
      }

      Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let output = text.trim(); 
                if (output === "") return;

                let parts = output.split(" ");
                if (parts.length >= 2) {
                    volumeContainer.volLevel = parseFloat(parts[1]);
                    volumeContainer.isMuted = output.includes("[MUTED]");
                }
            }
        }
      }

      function runWpctl(args, argsb) {
        let cmd = "wpctl " + args + " @DEFAULT_AUDIO_SINK@ " + argsb;
        Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash", "-c", "' + cmd + '"]; running: true }', volumeContainer);
         
        volProc.running = true
        //widgetRoot.activityVDetected()
      }
    
      Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Up) {
            runWpctl("set-volume", "5%+");
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            runWpctl("set-volume", "5%-");
            event.accepted = true;
        } else if (event.key === Qt.Key_M) {
            runWpctl("set-mute", "toggle");
            event.accepted = true;
          } else if (event.key === Qt.Key_T) {
            console.log("Knappen funkar!");
            event.accepted = true;
          }
      }

      Timer {
        interval: 200         
        running: true
        repeat: true
        onTriggered: volProc.running = true
      }

      Rectangle {
        id: volFill

        readonly property real maxDiameter: Math.sqrt(Math.pow(parent.width, 2) + Math.pow(parent.height, 2))
        property real animScale: 1.0

        width: Math.max(0, (maxDiameter * volumeContainer.smoothedVol) * animScale)
        height: width
        radius: width / 2

        color: volumeContainer.isMuted ? "#F57F82" : "#F57F82"
        opacity: 0.5
        anchors.centerIn: parent


        SequentialAnimation {
          id: pulseAnim
          running: volumeContainer.smoothedVol > 0.02 && !volumeContainer.isMuted
          loops: Animation.Infinite

          NumberAnimation { target: volFill; property: "animScale"; to: 1.08; duration: 900; easing.type: Easing.InOutSine }
          NumberAnimation { target: volFill; property: "animScale"; to: 1.0;  duration: 1100; easing.type: Easing.InOutSine }
          NumberAnimation { target: volFill; property: "animScale"; to: 1.04; duration: 500; easing.type: Easing.InOutSine }
          NumberAnimation { target: volFill; property: "animScale"; to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
        }

        Behavior on opacity {
          NumberAnimation { duration: 200 }
        }

        // En säkerhetsåtgärd: Om animationen inte körs, se till att skalan är exakt 1.0
        onVisibleChanged: if (!visible) animScale = 1.0
      }
    }
  }
}
