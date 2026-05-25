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

  property string wcBackgroundImageP: "novalue"
  property int testWc: 1


  FileView {
    id: jsonFile
    path: Qt.resolvedUrl("./scripts/settings.json")
      // Forces the file to be loaded by the time we call JSON.parse().
      // see blockLoading's property documentation for details.
    blockLoading: true
  }

  readonly property var wsBgtest: JSON.parse(jsonFile.text())

  function test(ws) {
    let theme = wsBgtest[ws.toString()];
    widgetRoot.wcBackgroundImageP = theme.img;
    console.log(widgetRoot.wcBackgroundImageP);
  }

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
      id: testRec 
      width: 500 
      height: 500
      color: "black"
      //anchors.centerIn: parent - ifall du vill ha den mitt på skärmen
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: 10
      focus: true
      radius: 12
      transformOrigin: Item.Top
      opacity: visible ? 1 : 0
      scale: visible ? 1 : 0
      visible: false 

      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      Keys.onEscapePressed: widgetRoot.closeTestRequested()

      Component.onCompleted: {
        testRec.visible = true
        test(widgetRoot.testWc) 
      }

      //ColorAnimation on color { from: "black"; to: "blue"; duration: 2000 }

    }
  }
}
