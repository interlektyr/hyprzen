pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
  id: root

  //Zen_settings
  FileView {
    id: zenSettingsRead
    path: Qt.resolvedUrl("./scripts/zen_settings.json")
    blockLoading: true
    watchChanges: true
    onFileChanged: this.reload()
  }

  readonly property var fetchZenSettings: JSON.parse(zenSettingsRead.text())
  property bool enableDynamicWallpapers: fetchZenSettings.enable_dw

  //Hyprland-Socket
  property int activeWorkspace: 1
  property bool showWCIndicatorBool: false

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event.name === "workspace") {
        let wsId = parseInt(event.data);
        root.activeWorkspace = wsId;

        if (root.enableDynamicWallpapers == true) {
          updateEnvironment();
        }
        root.showWCIndicatorBool = true;
        if (wcIndicatorLoader.item && typeof wcIndicatorLoader.item.triggerShow === "function") {
            wcIndicatorLoader.item.triggerShow();        
        }
      }
    }
  }

  //Dynamic wallpapers 
  property var newWallpaper: fetchZenSettings.dw[root.activeWorkspace]

  Process {
    id: awwwProcess
  }

  function updateEnvironment() {
    let target = root.newWallpaper

    awwwProcess.command = [
    "awww", "img", 
    "--transition-type", "fade",
    target
    ];

    awwwProcess.running = true;
  }

  //WCIndicator
  Loader {
    id: wcIndicatorLoader
    active: root.showWCIndicatorBool
    source: "WCIndicator.qml" 
  }

  property int timeCloseWCIndicator: 3000
  property var accentColor: "pink"

  //NotificationWidget 
  property bool showNoteWidget: false
  property bool passiveNoteWidget: true
  property bool setDoNotDisturbNote: false

  Loader {
    id: noteWidgetLoader
    active: true 
    source: "NotificationWidget.qml"
  }

  //StatusWidget
  property bool toggleStatusWidget: false
  property var typeOfStat: "volume" 

  Timer {
    id: timeCloseStatusWidget
    interval: root.typeOfStat == "connections" ? 10000 : 4000
    running: root.toggleStatusWidget = true
    repeat: true
    onTriggered: root.toggleStatusWidget = false;
  }

  //AppCommander
  property bool toggleAppCommander: false
  property string termLaunchArg: fetchZenSettings.launch_term

  Loader {
    id: appCommanderLoader
    active: ZenServices.toggleAppCommander
    source: "Appcommander.qml" 
  }
}

