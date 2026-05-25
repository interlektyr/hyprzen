import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Quickshell.Io

//VOLUME

Scope {
  id: widgetRoot
  
  signal closeVRequested()
  signal activityVDetected()

  PanelWindow {
    id: testWidget
    implicitWidth: Screen.width 
    implicitHeight: Screen.height
    color: "transparent" 

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "volume-hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1

    TapHandler {
      onTapped:
      widgetRoot.closeVRequested()
    }

    Rectangle {
      id: volumeContainer 
      width: 450 
      height: 280
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
      clip: true 
      

      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      Keys.onEscapePressed: widgetRoot.closeVRequested()

      Component.onCompleted: {
        forceActiveFocus();
        volumeContainer.visible = true;
        console.log("Fokus");
      } 

      property real volLevel: 0 // 0.0 till 1.0
      property bool isMuted: false
      property real smoothedVol: 0

      onVolLevelChanged: smoothedVol = volLevel

      Behavior on smoothedVol {
        NumberAnimation { 
            duration: 250 // Tiden det tar för mätaren att "glida"
            easing.type: Easing.OutCubic // En mjuk inbromsning
          }
      }

      // --- Logik för att hämta volym ---
      Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let output = text.trim(); // Exempel: "Volume: 0.45" eller "Volume: 0.45 [MUTED]"
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
        
        // Uppdatera mätaren direkt efter kommandot
        //volProc.running = false 
        volProc.running = true
        widgetRoot.activityVDetected()
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
        interval: 200 // Volym vill man ofta uppdatera lite oftare
        running: true
        repeat: true
        onTriggered: volProc.running = true
      }

      // --- Cirkeln (Visualiseringen) ---
      Rectangle {
      id: volCircle
    
      // Diagonal-beräkning
      readonly property real maxDiameter: Math.sqrt(Math.pow(parent.width, 2) + Math.pow(parent.height, 2))
    
      // Vi animerar denna egenskap direkt
      property real animScale: 1.0 

      // Storleken: Vi använder Math.max för att säkerställa att den inte blir "negativ" 
      // eller ogiltig under beräkningen.
      width: Math.max(0, (maxDiameter * volumeContainer.smoothedVol) * animScale)
      height: width
      radius: width / 2

      color: volumeContainer.isMuted ? "#F57F82" : "#F57F82"
      opacity: 0.5
      anchors.centerIn: parent

      // Istället för Behavior på width (som kan krocka), 
      // så låter vi volymändringar ske direkt eller via en egen liten animation
    
      SequentialAnimation {
            id: pulseAnim
            running: volumeContainer.smoothedVol > 0.02 && !volumeContainer.isMuted
            loops: Animation.Infinite

            NumberAnimation { target: volCircle; property: "animScale"; to: 1.08; duration: 900; easing.type: Easing.InOutSine }
            NumberAnimation { target: volCircle; property: "animScale"; to: 1.0;  duration: 1100; easing.type: Easing.InOutSine }
            NumberAnimation { target: volCircle; property: "animScale"; to: 1.04; duration: 500; easing.type: Easing.InOutSine }
            NumberAnimation { target: volCircle; property: "animScale"; to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
      }

      Behavior on opacity {
      NumberAnimation { duration: 200 }
      }

      // En säkerhetsåtgärd: Om animationen inte körs, se till att skalan är exakt 1.0
      onVisibleChanged: if (!visible) animScale = 1.0
      }

      // --- Text i mitten ---
      Text {
        text: volumeContainer.isMuted ? "off" : Math.round(volumeContainer.volLevel * 100) + "%"
        font.family: "Work Sans"
        color: "black"
        font.pixelSize: volumeContainer.isMuted ? parent.width * 0.5 : parent.width * 0.3
        //font.bold: true
        font.weight: Font.ExtraBold
        font.letterSpacing: -2
        anchors.centerIn: parent
      }

      Text {
        text: "Volume"
        color: "black"
        font.pixelSize: 15
        font.family: "DepartureMono Nerd Font Mono"
        anchors.top: parent.top
        anchors.right: parent.right 
        anchors.topMargin: 10
        anchors.rightMargin: 10

        OpacityAnimator on opacity {
          from: 0; to: 1; duration: 150 
          running: true
        }
      }

      Text {
        text: "[\uf062/\uf063] vol +/- [m] mute [esc] quit"
        color: "black"
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
    }
  }
}
