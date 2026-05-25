import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Quickshell.Io

//WORKSPACE 

Scope {
  id: widgetRoot
  signal closeRequested()
  signal activityDetected()

  property int currentWorkspace: Hyprland.focusedMonitor.activeWorkspace.id
  property string wcbgPath: ""

  PanelWindow {
    id: workspaceOverlay
    implicitWidth: Screen.width 
    implicitHeight: Screen.height
    color: "transparent" 

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "workspace-hud"
    //WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.exclusiveZone: -1
    //Hyprland.usingLua: true

    TapHandler {
      onTapped:
      widgetRoot.closeRequested()
    }

    Rectangle {
      id: mainContainer 
      width: 450 
      height: 280
      color: "#F8F9E8"
      anchors.centerIn: parent
      focus: true
      radius: 12
      transformOrigin: Item.Top
      opacity: visible ? 1 : 0
      scale: visible ? 1 : 0
      visible: false
      antialiasing: true 
      
      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      Keys.onEscapePressed: widgetRoot.closeRequested()

      Keys.onPressed: (event) => { 
        if (event.key === Qt.Key_Right) {
          event.accepted = true; 
          //Hyprland.dispatch('workspace +1');
          Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "wc_next"])
          widgetRoot.activityDetected();
        } 
        else if (event.key === Qt.Key_Left) {
          event.accepted = true;
          //Hyprland.dispatch('workspace -1');
          Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "wc_prev"])
          widgetRoot.activityDetected();
        }
        else if (event.key === Qt.Key_1) {
          event.accepted = true;
          //Hyprland.dispatch('workspace 1');
          Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "wc_1"])
          widgetRoot.activityDetected();
        }
        else if (event.key === Qt.Key_2) {
          event.accepted = true;
          //Hyprland.dispatch('workspace 2');
          Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "wc_2"])
          widgetRoot.activityDetected();
        }
        else if (event.key === Qt.Key_3) {
          event.accepted = true;
          //Hyprland.dispatch('workspace 3');
          Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "wc_3"])
          widgetRoot.activityDetected();
        }
        else if (event.key === Qt.Key_4) {
          event.accepted = true;
          //Hyprland.dispatch('workspace 4');
          Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "wc_4"])
          widgetRoot.activityDetected();
        }
        else if (event.key === Qt.Key_5) {
          event.accepted = true;
          //Hyprland.dispatch('workspace 5');
          Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "wc_5"])
          widgetRoot.activityDetected();
        }
        else if (event.key === Qt.Key_6) {
          event.accepted = true;
          //Hyprland.dispatch('workspace 6');
          Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "wc_6"])
          widgetRoot.activityDetected();
        }
        else if (event.key === Qt.Key_7) {
          event.accepted = true;
          //Hyprland.dispatch('workspace 7');
          Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "wc_7"])
          widgetRoot.activityDetected();
        }
        else if (event.key === Qt.Key_8) {
          event.accepted = true;
          //Hyprland.dispatch('workspace 8');
          Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "wc_8"])
          widgetRoot.activityDetected();
        }
        else if (event.key === Qt.Key_9) {
          event.accepted = true;
          //Hyprland.dispatch('workspace 9');
          Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "wc_9"])
          widgetRoot.activityDetected();
        } 
        else if (event.key === Qt.Key_0) {
          event.accepted = true;
          //Hyprland.dispatch('workspace 10');
          Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "wc_10"])
          widgetRoot.activityDetected();
        } 
      }

      //Keys.onEscapePressed: widgetRoot.closeRequested()
      //Keys.onRightPressed: {
        //Hyprland.dispatch('exec ~/.config/hypr/hyp_win.sh f');
      //  Hyprland.dispatch('workspace +1');
      //  widgetRoot.activityDetected();
      //}

      //Keys.onLeftPressed: {
        //Hyprland.dispatch('exec ~/.config/hypr/hyp_win.sh b');
      //  Hyprland.dispatch('workspace -1');
      //  widgetRoot.activityDetected();
      //}

      Component.onCompleted: {
        mainContainer.visible = true
      }
        
      Image {
        id: bgImage
        anchors.fill: parent
        source: widgetRoot.wcbgPath
        //source: "assets/wallpapers/1.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.5
        visible: false
        }
 
      Rectangle {
        id: maskShape
        anchors.fill: parent 
        radius: mainContainer.radius
        visible: false 
      }

      OpacityMask {
        anchors.fill: parent 
        source: bgImage
        maskSource: maskShape
        opacity: 0.5
      }

      Text {
        text: "Workspaces"
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
        text: "[\uf060/\uf061] prev/next [1-0] jump [esc] quit"
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

      Text {
        //text: "2"
        text: widgetRoot.currentWorkspace
        color: "#F57F82"
        font.family: "Work Sans"
        font.pixelSize: parent.width * 0.4 
        //font.bold: true 
        //font.letterSpacing: -10
        font.weight: Font.ExtraBold
        anchors.centerIn: parent 

        OpacityAnimator on opacity {
          from: 0; to: 1; duration: 150 
          running: true
        }
      }
    }
  }
}
