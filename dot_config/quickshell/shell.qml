import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications


ShellRoot {
  id: root

  //SOCKET
    Connections {
      target: Hyprland
      function onRawEvent(event) {
        if (event.name === "workspace") {
          let wsId = parseInt(event.data);
          root.activeWorkspace = wsId;
          //root.workspaceUpdateTrigger = Math.random();
          //console.log("Test: " + root.activeWorkspace);
          updateEnvironment(wsId);
          //test nedan
          root.showWCIndicatorBool = true;
          if (wcIndicatorLoader.item && typeof wcIndicatorLoader.item.triggerShow === "function") {
            wcIndicatorLoader.item.triggerShow();
          }
          //root.showWorkspaceWidget = true;
          //autoCloseTimer.restart();
        }
        //if (event.name === "monitorremoved") {
        //  Quickshell.execDetached([Quickshell.env("HOME") + "/.config/quickshell/scripts/zen_terminal_wrapper.sh", "monitor"]);
        //}
      }
    }

    //NOTIFICATION SERVICE 
    NotificationServer {
      id: notifyService
    }
       
    // PROPERTIES
    //
    // workspaceIndicator
    property int activeWorkspace: 1
    property color activeAccent: "#ffffff"
    // test 
    property bool showWCIndicatorBool: false


    FileView {
      id: jsonFile
      path: Qt.resolvedUrl("./scripts/settings.json")
      // Forces the file to be loaded by the time we call JSON.parse().
      // see blockLoading's property documentation for details.
      blockLoading: true
      watchChanges: true
      onFileChanged: this.reload()
    }

    readonly property var workspaceThemesRemote: JSON.parse(jsonFile.text())

    readonly property var workspaceThemes: {
        "1": { img: "1.jpg", color: "#F5D098" }, // Sky Blue
        "2": { img: "2.jpg", color: "#DBE6AF" }, // Sea Green
        "3": { img: "3.jpg", color: "#CAE0A7" }, // Magenta
        "4": { img: "4.jpg", color: "#ADDEB9" }, // Sandy Brown
        "5": { img: "clay-banks-u27Rrbs9Dwc-unsplash.jpg", color: "#ACE0D4" },
        "6": { img: "6.jpg", color: "#AFDFE6" },
        "7": { img: "7.jpg", color: "#B2CFED" },
        "8": { img: "8.jpg", color: "#D0BBF0" },
        "9": { img: "9.jpg", color: "#F3C0E5" },
        "10": { img: "0.jpg", color: "#F8F9E8" },
        "default": { img: "default.jpg",    color: "#F8F9E8" }
    }

    readonly property string wallPath: "/.config/quickshell/assets/wallpapers/"

    //WorkspaceWidget
    property bool showWorkspaceWidget: false 
    property string wcBackgroundImage: "assets/wallpapers/1.jpg"

    //ClockWidget
    property bool showClockWidget: false
    property bool useCTimer: true

    //BatteryWidget
    property bool showBatteryWidget: false 
    property bool useBTimer: true

    //VolumeWidget
    property bool showVolumeWidget: false 
    property bool useVTimer: true

    //AppCommander
    property bool showACWidget: false

    //Power Menu 
    property bool showPowerMWidget: false

    //System Menu
    property bool showSMWidget: false

    //Stasher
    property bool showStasherWidget: false

    //NotificationWidget 
    property bool showNoteWidget: false
    property bool passiveNoteWidget: true
    property bool setDoNotDisturbNote: false

    // GLOBALSHORTCUTS
    // WorkspaceWidget
    GlobalShortcut {
        name: "workspace_hud"
        onPressed: {
            root.showWorkspaceWidget = true;
            autoCloseTimer.restart(); // Starta om timern varje gång man trycker
        }
    }

    // ClockWidget 
    GlobalShortcut {
        name: "clock_hud"
        onPressed: {
            root.showClockWidget = true;
            autoCloseCTimer.restart(); // Starta om timern varje gång man trycker
        }
    }

    GlobalShortcut {
        name: "clock_hud_per"
        onPressed: {
            root.useCTimer = false 
            root.showClockWidget = true;
            autoCloseCTimer.stop();
        }
    }

    // BatteryWidget 
    GlobalShortcut {
        name: "battery_hud"
        onPressed: {
            root.showBatteryWidget = true;
            autoCloseBTimer.restart(); // Starta om timern varje gång man trycker
        }
    }

    // VolumeWidget 
    GlobalShortcut {
        name: "volume_hud"
        onPressed: {
            root.showVolumeWidget = true;
            autoCloseVTimer.restart(); // Starta om timern varje gång man trycker
        }
    }

    //AppCommander
    GlobalShortcut {
      name: "appcommander_hud"
      onPressed: {
          root.showACWidget = true;
          //autoCloseVTimer.restart(); // Starta om timern varje gång man trycker
      }
    }

    //Power Menu
    GlobalShortcut {
      name: "power_hud"
      onPressed: {
        root.showPowerMWidget = true;
      }
    }
  
    //System Menu
    GlobalShortcut {
        name: "zensys_hud"
        onPressed: { 
            root.showSMWidget = true;
        }
    }

    //Stasher
    GlobalShortcut {
      name: "stasher_hud"
      onPressed: {
        root.showStasherWidget = true;
      }
    }

    //NotificationWidget
    GlobalShortcut {
      name: "notificationWidget_hud"
      onPressed: {
        root.passiveNoteWidget = false;
        autoCloseNoteWidgetTimer.stop();
        root.showNoteWidget = true;
      }
    }

    // Where is my LockScreen
    GlobalShortcut {
        name: "lockTheScreen"
        description: "Toggles Where Is My LockScreen"
        onPressed: { 
            launchLockScreen.startDetached();
        }
    }
    
    // TIMERS
    // Timer workspace_hud
    Timer {
        id: autoCloseTimer
        interval: 1500
        running: false
        onTriggered: root.showWorkspaceWidget = false
    }
    
    // Timer Clock
    Timer {
        id: autoCloseCTimer
        interval: 3000
        running: false
        onTriggered: {
          if (root.useCTimer) {
            root.showClockWidget = false;
          }
        }
    }

    // Battery Clock
    Timer {
        id: autoCloseBTimer
        interval: 2500
        running: false
        onTriggered: {
          if (root.useBTimer) {
            root.showBatteryWidget = false;
          }
        }
    }

    // Volume Clock
    Timer {
        id: autoCloseVTimer
        interval: 2500
        running: false
        onTriggered: {
          if (root.useVTimer) {
            root.showVolumeWidget = false;
          }
        }
    }

    // NotificationsWidget
    Timer {
        id: autoCloseNoteWidgetTimer
        interval: 3000
        running: false
        onTriggered: {
          if (root.passiveNoteWidget) {  
            root.showNoteWidget = false; 
          }
        }
    }


    // PROCESS
    // LockScreen
    Process {
        id: launchLockScreen
        running: false
        command: ["quickshell", "-p", Quickshell.env("HOME") + "/.config/quickshell/WIMLockScreen.qml"]
    }

    //workspaceIndicator
    Process {
        id: awwwProcess
    }

    // Funktion som byter bakgrund
    // Alternativt test med workspaceThemesRemote, byt ut denna mot workspaceThemes om du vill återställ 
    function updateEnvironment(ws) {
        let theme = workspaceThemesRemote[ws.toString()] || workspaceThemesRemote["default"];
        
        root.activeAccent = theme.color;
        //root.wcBackgroundImage = "assets/wallpapers/" + theme.img;
        //återställ ovan om du vill gå tillbaka
        root.wcBackgroundImage = theme.img;
        console.log(root.wcBackgroundImage);

        // Byt bakgrund via swww
        // Denna är den utsprunliga vommsndot med värden definerade i workspaceThemes
        //awwwProcess.command = [
        //  "awww", "img", 
        //  "--transition-type", "fade",
        //  Quickshell.env("HOME") +
        //  root.wallPath + theme.img
        //];
        //Uppdaterad version 
        awwwProcess.command = [
          "awww", "img", 
          "--transition-type", "fade",
          theme.img
        ];

        awwwProcess.running = true;
    
    }
    //awww img --transition-type fade ~/.config/hypr/wallpapers/1.jpg

    // LOADERS 
    // WorkspaceWidget
    Loader {
        id: workspaceLoader
        active: root.showWorkspaceWidget
        source: "WorkspaceWidget.qml" 
        //onLoaded: if (item) item.wcbgPath = root.wcBackgroundImage;
        onLoaded: {
          if (item) {
            item.wcbgPath = Qt.binding(() => root.wcBackgroundImage);
            //item.currentWs = Qt.binding(() => root.currentWorkspace);
          }
        } 
    }

    //WS-Indicator
    Loader {
      id: wcIndicatorLoader
      //active: true
      active: root.showWCIndicatorBool
      source: "WCIndicator.qml"
 
      onLoaded: {
        if (item) {
          item.currentWs = Qt.binding(() => root.activeWorkspace);
          item.accentColor = Qt.binding(() => root.activeAccent);
          //console.log("Koppling till widgeten")
        }
      }
    }
    
    // Clock
    Loader {
      id: clockLoader
      active: root.showClockWidget
      source: "ClockWidget.qml" 
    }

    // Battery
    Loader {
      id: batteryLoader
      active: root.showBatteryWidget
      source: "BatteryWidget.qml" 
    }

    // Volume
    Loader {
      id: volumeLoader
      active: root.showVolumeWidget
      source: "VolumeWidget.qml" 
    }

    // AppCommander
    Loader {
      id: acLoader
      active: root.showACWidget
      source: "AppCommander.qml" 
    }

    // Power Menu
    Loader {
      id: powerMLoader
      active: root.showPowerMWidget
      source: "PowerMenu.qml"
    }

    // System 
    Loader {
      id: sMLoader
      active: root.showSMWidget 
      source: "SystemMenu.qml" 
    } 

    //Stasher
    Loader {
      id: stasherLoader
      active: root.showStasherWidget
      source: "Stasher.qml"
    }

    //NotificatonWidget
    Loader {
      id: noteWidgetLoader
      active: root.showNoteWidget
      source: "NotificationWidget.qml"

      onLoaded: {
        if (item) {
          item.passiveWidget = Qt.binding(() => root.passiveNoteWidget);
          item.doNotDisturbSet = Qt.binding(() => root.setDoNotDisturbNote);
        }
      }

    }


    // CONNECTIONS
    // workspaceLoader
    Connections {
      target: workspaceLoader.item 
      ignoreUnknownSignals: true

      function onCloseRequested() {
        root.showWorkspaceWidget = false;
      }

      function onActivityDetected() {
        autoCloseTimer.restart();
      }
    }
    
    // Clock
    Connections {
      target: clockLoader.item
      ignoreUnknownSignals: true

      function onCloseCRequested() {
        root.showClockWidget = false
      }
    }

    // Battery
    Connections {
      target: batteryLoader.item
      ignoreUnknownSignals: true

      function onCloseBRequested() {
        root.showBatteryWidget = false
      }

      function onActivityBDetected() {
        autoCloseBTimer.restart();
      }
    }

    // Volume
    Connections {
      target: volumeLoader.item
      ignoreUnknownSignals: true

      function onCloseVRequested() {
        root.showVolumeWidget = false
      }

      function onActivityVDetected() {
        autoCloseVTimer.restart();
      }
    }

    // AppCommander
    Connections {
      target: acLoader.item
      ignoreUnknownSignals: true

      function onCloseACRequested() {
        root.showACWidget = false
      }
    }

    //PowerMenu
    Connections {
      target: powerMLoader.item 
      ignoreUnknownSignals: true 

      function onClosePowerMRequested() {
        root.showPowerMWidget = false
      }
    }

    // System
    Connections {
      target: sMLoader.item
      ignoreUnknownSignals: true

      function onCloseSMRequested() {
        root.showSMWidget = false
      }
    }

    //Stasher 
    Connections {
      target: stasherLoader.item
      ignoreUnknownSignals: true 

      function onCloseStasherRequested() {
        root.showStasherWidget = false
      }
    }
    
    //Notification 
    Connections {
      target: notifyService 
      function onNotification(n) {
        if (noteWidgetLoader.status == Loader.Ready && root.passiveNoteWidget == false) {
           NotificationList.add(n);
        } else {
           NotificationList.add(n);
           if (root.setDoNotDisturbNote == false) {
             root.passiveNoteWidget = true
             root.showNoteWidget = true;
             autoCloseNoteWidgetTimer.restart();
           }
        }
      }
    }

    Connections {
      target: noteWidgetLoader.item
      ignoreUnknownSignals: true 

      function onCloseNoteWidgetRequested() {
        root.showNoteWidget = false
      }

      function onDoNotDisturb() {
        if (root.setDoNotDisturbNote == false) {
          root.setDoNotDisturbNote = true;
        } else {
          root.setDoNotDisturbNote = false
        }
      }
    }


    // IPC-Handlers
    //qs ipc call zen_shell setWCWidgetBG "/home/kristian/.config/hypr/wallpapers/3.jpg"
    IpcHandler {
      target: "zen_shell"
      function setWCWidgetBG(path: string) {
        root.wcBackgroundImage = "file://" + path;
      }
    }

}


//ShellRoot {
//  id: root 

  
// FloatingWindow {
//     visible: true
//     width: 200
//     height: 100

//     Text {
//         anchors.centerIn: parent
//         text: "Hello, Quickshell!"
//         color: "#0db9d7"
//         font.pixelSize: 18
//       }

//     TapHandler {
//       onTapped:
//       Qt.quit()
//     }

// }


